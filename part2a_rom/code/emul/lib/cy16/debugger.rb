require 'readline'
require 'abbrev'
require 'pp'

module CY16

  class Debugger

    attr_accessor :data_segments

    KEYWORDS = %w{ break continue show breakpoints mem regs help exit step stepi trace print }.sort
    KEYWORDS_ABBR = KEYWORDS.abbrev

    Readline.completion_append_character = " "
    Readline.completion_proc = proc { |s| KEYWORDS.grep( /#{Regexp.escape(s)}/ ) }

    def initialize
      @break_next = false
      @breakpoints = []
      @breakpoints_once = []
      @exit = false
      @auto_mem = false
      @auto_reg = false
      @do_trace_call = false
      @depth = 0
    end

    def debug(pc, di, regs, mem)
      trace_call(pc, di, regs) if @do_trace_call
      if break?(pc, regs, mem)
        puts "[!] breaking at 0x%04x: #{di}" % pc
        do_regs(pc, di, regs, mem) if @auto_reg
        do_mem(pc, di, regs, mem) if @auto_mem
        handle_user_input(pc, di, regs, mem)
      end
    end

    def trace_call(pc, di, regs)
      case di.opcode.name
      when "call"
        prefix = " " * (4 * @depth)
        addr = di.instruction.args.first
        s = []
        (0..6).each do |i|
          s << "r#{i} = 0x%x" % [ regs[i] ]
        end
        puts "#{prefix}0x%04x call 0x%04x, %s" % [pc, addr.rexpr, s.join(', ')]
        @depth += 1
      when "ret"
        @depth -= 1
        prefix = " " * (4 * @depth)
        puts "#{prefix}0x%04x ret, r0 = 0x%x, r2 = 0x%x" % [pc, regs[0], regs[2]]
      end
    end

    def handle_user_input(pc, di, regs, mem)
      while line = Readline.readline("> ", true)
        if line =~ /^\s*([^\s]+)\s*(.*)/ then
          command = KEYWORDS_ABBR[$1] || $1
          args = $2.split(/\s/)
          begin
            ret = send("do_#{command}".to_sym, pc, di, regs, mem, *args)
            break if ret
            if @exit == true
              return false
            end
          rescue NoMethodError => e
            puts "[!] no command: #{command}"
          end
        else
          puts "[!] wrong command: #{line}"
        end
      end
      return true
    end

    def do_help(pc, di, regs, mem, *args)
      puts "break addr: add a breakpoint at given address"
      puts "del addr: remove breakpoint at given address"
      puts "continue: continue the program execution until next breakpoint"
      puts "step: break at next instruction"
      puts "step: break at next instruction (stepping over function calls)"
      puts "show (breakpoints|regs|mem): show the specified object"
      puts "trace: enable / disable call tracing"
      puts "exit: exit the debugger"
    end

    def do_trace(pc, di, regs, mem, *args)
      @do_trace_call = !@do_trace_call
      return false
    end

    def do_continue(pc, di, regs, mem, *args)
      return true
    end

    def do_step(pc, di, regs, mem, *args)
      if di.opcode.name == "call" then
        @breakpoints_once << pc + di.bin_length
      else
        @break_next = true
      end

      return true
    end

    def do_stepi(pc, di, regs, mem, *args)
      @break_next = true
      return true
    end

    def do_exit(pc, di, regs, mem, *args)
      @exit = true
      return false
    end

    def do_print(pc, di, regs, mem, *args)
      unless args.size == 1 then
        puts "[!] print: missing argument"
        return false
      end

      addr = args.shift
      unless addr =~ /\h+/ then
        puts "[!] print: wrong argument #{addr}"
        return false
      end
      addr = addr.to_i(16)
      v = rw(mem, addr)
      puts "0x%04x : 0x%04x" % [addr, v]
      return false
    end

    def rw(mem, addr)
      return mem.data[addr] | (mem.data[addr+1] << 8)
    end

    def do_break(pc, di, regs, mem, *args)
      unless args.size == 1 then
        puts "[!] break: missing argument"
        return false
      end

      addr = args.shift
      unless addr =~ /\h+/ then
        puts "[!] break: wrong argument #{addr}"
        return false
      end
      @breakpoints << addr.to_i(16)
      return false
    end

    def do_del(pc, di, regs, mem, *args)
      unless args.size == 1 then
        puts "[!] del: missing argument"
        return false
      end

      addr = args.shift
      unless addr =~ /\h+/ then
        puts "[!] del: wrong argument #{addr}"
        return false
      end

      @breakpoints.delete(addr.to_i(16))
      return false
    end


    def do_breakpoints(pc, di, regs, mem, *args)
      puts "breakpoints : " << @breakpoints.sort.map {|x| "0x%04x" % x}.join(' ')
      unless @breakpoints_once.empty?
        puts "breakpoints (once) : " << @breakpoints_once.sort.map {|x| "0x%04x" % x}.join(' ')
      end
      return false
    end

    def do_regs(pc, di, regs, mem, *args)
      puts "\n[!] registers :"
      (0..15).each do |i|
        print "r%02d = 0x%04x " % [ i, regs[i] ]
        puts if (i + 1) % 8 == 0
      end
      puts
      return false
    end

    def do_mem(pc, di, regs, mem, *args)
      @data_segments.each do |seg|
        addr = seg.first
        len = seg.last - seg.first
        data = mem.data[seg]
        puts "\n[!] dump at 0x%04x, %d bytes\n" % [ addr, len ]
        0.upto(len-1) do |i|
          print ("0x%02x  " % [ addr + i ]) if ( i % 8) == 0
          print ("%02x " % [ data[i] ])
          puts  if ( (i+1) % 8 ) == 0
        end
        puts
      end
      return false
    end

    def do_show(pc, di, regs, mem, *args)
      unless args.size == 1 then
        puts "[!] show: missing argument"
        return false
      end

      obj = args.shift
      case obj
      when /breakpoints/
        return do_breakpoints(pc, di, regs, mem, *args)
      when /reg/
        return do_regs(pc, di, regs, mem, *args)
      when /mem/
        return do_mem(pc, di, regs, mem, *args)
      else
        puts "[!] show: wrong argument #{obj}"
      end
    end

    def break_at(addr)
      @breakpoints << addr unless @breakpoints.include?(addr)
    end

    def del_breakpoint(addr)
      @breakpoints.delete(addr)
    end

    def break?(pc, regs, mem)
      return true if @breakpoints.include?(pc)

      if (pc == 0x4814) && (rw(mem, 0xc000) == 1) && (rw(mem, 0x4144) == 0x13) && (regs[6] == 1) && (regs[14] == 0) then
        return true
      end

      if @breakpoints_once.include?(pc) then
        @breakpoints_once.delete(pc)
        return true
      end

      if @break_next then
        @break_next = false
        return true
      end

      return false
    end
  end

end
