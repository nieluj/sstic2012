#!/usr/bin/env ruby

require 'metasm'
require 'metasm/cpu/cy16'
#include Metasm

require 'cy16/loader'
require 'cy16/alu'

module CY16

class State
  attr_accessor :mem,:gpr, :pc, :z, :c, :o, :s, :di
  def initialize
    @mem = []
  end

  def flags
    "z = #@z, c = #@c, o = #@o, s = #@s"
  end

  def registers
    s = ""
    (0..15).each do |i|
      s << "r#{i} = 0x%04x " % [ @gpr[i] ]
      s << "\n" if (i + 1) % 4 == 0
    end
    s
  end

  def <<(a)
    @mem << a
  end

  def rw(a)
    @mem.each do |addr, len, data|
      p = addr
      data.pack('C*').unpack('v*').each do |w|
        return w if p == a
        p +=2
      end
    end
    return nil
  end

  def rr(rsym)
    if rsym.to_s =~ /r(\d+)/ then
      return @gpr[$1.to_i]
    end
    raise "register #{sym} not found"
  end

  def cmp(other)
    #puts "comparing states 0x%04x <=> 0x%04x" % [@pc, other.pc]
    ret = []
    @gpr.each_with_index do |r, i|
      if r != other.gpr[i] then
        ret << [ :reg, i, r, other.gpr[i] ]
      end
    end
    %w{ z c o s }.each do |f|
      fv, ofv = self.send(f.to_sym), other.send(f.to_sym)
      if fv != ofv then
        ret << [ :flag, f, fv , ofv ]
      end
    end
    @mem.each_with_index do |a, index|
      addr, len, data = *a
      oaddr, olen, odata = *other.mem[index]
      raise unless addr == oaddr and len == olen

      wdata = data.pack('C*').unpack('v*')
      wodata = odata.pack('C*').unpack('v*')
      wdata.each_with_index do |w, i|
        if w != wodata[i] then
          ret << [ :data, addr, w, wodata[i] ]
        end
        addr += 2
      end
    end
    return ret
  end

  def pp_cmp(other, level)
    res = self.cmp(other)
    res.each do |a|
      case a.first
      when :reg
        next unless a[1] < 8
        puts "    " * level + "r%02d: 0x%04x => 0x%04x" % [ a[1], a[2], a[3] ]
      when :flag
        puts "    " * level + "#{a[1]}: #{a[2]} => #{a[3]}"
      when :data
        puts "    " * level + "0x%04x: 0x%04x => 0x%04x" % [ a[1], a[2], a[3] ]
      end
    end
  end

  def memdump
    s = ""
    @mem.each do |addr, len, data|
      s << "* dump at 0x%04x, %d bytes\n" % [ addr, len ]
      0.upto(len-1) do |i|
        s << "0x%02x  " % [ addr + i ] if ( i % 8) == 0
        s << "%02x " % [ data[i] ]
        s << "\n" if ( (i+1) % 8 ) == 0
      end
      s << "\n"
    end
    s
  end
end

# Implements an Encoded-data like interface
class Memory
  attr_accessor :ptr, :data

  def initialize(size = 0x10000)
    @data = Array.new(size, 0)
    @ptr = 0
  end

  def decode_imm(what, endianness)
    r = case what
    when :u16
      b1, b2 = @data[@ptr], @data[@ptr+1]
      @ptr += 2
      r_little = (b2 & 0xff) | ((b1 & 0xff) << 8)
      r_big    = (b1 & 0xff) | ((b2 & 0xff) << 8)
      #puts "r_little = %016b, %04x" % [r_little, r_little]
      @endianness == :little ? r_little : r_big
    else
      raise "#{what}"
    end
    return r
  end

end

class Emulator
  attr_accessor :gpr, :z, :s, :c, :o, :mem, :client
  attr_reader :saved_states

  BITLEN = 16
  MAX_SIGNED_INT = 32767
  MIN_SIGNED_INT = -32768
  MAX_UNSIGNED_INT = 65535
  MIN_UNSIGNED_INT = 0
  ENTRY_POINTS = [ 0x0, 0x76, 0xf6, 0xe8 ]

  CONDITIONS = %w{ z nz c b nc ae s ns o no a be g ge l le }
  DUAL_OP_INS = %w{ mov add addc sub subb cmp and test or xor }
  PROG_CONTROL_INS = %w{ jmp ret call int }
  CONDITIONS.each do |cond|
    %w{ j c r }.each do |i|
      PROG_CONTROL_INS << "#{i}#{cond}"
    end
  end
  SINGLE_OP_INS = %w{ shr shl ror rol addi subi not neg cbw }
  MISC_INS = %w{ sti cli stc clc stX clX }

  INS_TO_TYPE = {}
  DUAL_OP_INS.each      {|ins| INS_TO_TYPE[ins] = :dual_op }
  PROG_CONTROL_INS.each {|ins| INS_TO_TYPE[ins] = :prog_control }
  SINGLE_OP_INS.each    {|ins| INS_TO_TYPE[ins] = :single_op }
  MISC_INS.each         {|ins| INS_TO_TYPE[ins] = :misc }

  def initialize(initial_sp_value = 0x5000, base_addr = 0x4000)
    @cpu = Metasm::CY16.new
    @alu = ALU.new
    @mem = Memory.new(0x10000)
    @base_addr = base_addr
    @top_stack = 0x5000
    @gpr = Array.new(16, 0)
    @gpr[15] = @top_stack
    @pc = 0
    @code = {}
    # flags
    @z = 0
    @c = 0
    @o = 0
    @s = 0
    @saved_states = []
    @data_segments = [ (0+@base_addr..0x74+@base_addr+2), (0xfe+@base_addr..0x144+@base_addr+2) ]
    @code_segments = [ (0x76+@base_addr..0xfc+@base_addr), (0x146+@base_addr..0x8a6+@base_addr) ]
    @stack_segment = [ (initial_sp_value - 1024 .. initial_sp_value) ]
    @readable_segments = @data_segments + @code_segments + @stack_segment
    @writeable_segments = @data_segments + @stack_segment

    @functions = {}
  end

  def add_funcs(*funcs)
    funcs.each do |f|
      @functions[f.addr] = f
    end
  end

  def set_flag(idx)
    flags = rw(0xc000)
    flags |= (1 << idx)
    ww(0xc000, flags)
  end

  def clear_flag(idx)
    flags = rw(0xc000)
    flags &= ~(1 << idx)
    ww(0xc000, flags)
  end

  def get_flag(idx)
    flags = rw(0xc000)
    (flags >> idx) & 1
  end

  def set_mem(addr, data)
    @mem.data[addr..addr+data.size-1] = data.bytes.to_a
  end

  def load_file(file, offset)
    loader = Loader.new(file, offset, @base_addr)
    @sc = loader.load_rom
    set_mem(@base_addr, @sc)
    execute(@base_addr)
  end

  #def show_flags
  #  puts "z = #@z, c = #@c, o = #@o, s = #@s"
  #end

  def show_registers
    (0..15).each do |i|
      print "r#{i} = 0x%04x " % [ @gpr[i] ]
      puts if (i + 1) % 4 == 0
    end
  end

  def save_state(di)
    st = State.new
    st.gpr = @gpr.dup
    st.pc = @pc
    st.z = gz
    st.c = gc
    st.o = go
    st.s = gs
    st.di = di.dup
    @data_segments.each do |seg|
      st << [seg.first, seg.last - seg.first, @mem.data[seg] ]
    end
    # save condition flags
    st << [0xc000, 2, @mem.data[0xc000,2] ]
    return st
  end

  def decode_next_ins(addr)
    @mem.ptr = addr
    di = @cpu.decode_instruction(@mem, addr)
    puts "invalid instruction at 0x%04x : 0x%04x" % [addr, rw(addr)] unless di
    return di 
  end

  def gz ; get_flag(0) ; end
  def cz ; clear_flag(0) ; end
  def sz ; set_flag(0) ; end

  def gc ; get_flag(1) ; end
  def cc ; clear_flag(1) ; end
  def sc ; set_flag(1) ; end

  def go ; get_flag(2) ; end
  def co ; clear_flag(2) ; end
  def so ; set_flag(2) ; end

  def gs ; get_flag(3) ; end
  def cs ; clear_flag(3) ; end
  def ss ; set_flag(3) ; end

  def gi ; get_flag(4) ; end
  def ci ; clear_flag(4) ; end
  def si ; set_flag(4) ; end

  def execute(addr, save_state = false, verbose = false, test_gen = nil, dbg = nil)
    @verbose, @pc = verbose, addr
    @test_gen = test_gen
    @trace = []

    if dbg then
      dbg.data_segments = @data_segments
    end

    while @pc
      di = decode_next_ins(@pc)
      #unless di
      #  @pc += 2
      #  next
      #end
      raise "invalid instruction at 0x#{@pc.to_s(16)}" unless di
      if save_state
        st = save_state(di)
        @saved_states << [@pc, st]
      end
      #show_registers
      #show_flags

      if dbg then
        ret = dbg.debug(@pc, di, @gpr, @mem)
        if ret == false
          puts "exiting from debugger ..."
          return false
        end
      end

      interpret(di)
      di.instruction.args.each { |a| handle_autoinc(a) }
    end
    #puts "execution finished at PC = #@pc"
    return true
  end

  def dump_mem(addr, size)
    0.upto(size-1) do |i|
      print "0x%02x  " % [ addr + i ] if ( i % 8) == 0
      print "%02x " % [ @mem.data[addr + i ] ]
      puts if ( (i+1) % 8 ) == 0
    end
  end

  def interpret(di)
    puts("[I] #{di}") if @verbose
    opname = di.opcode.name
    op_type = INS_TO_TYPE[opname]
    raise "cannot find instruction type for #{opname}" unless op_type
    self.send("do_#{op_type}", di)
  end

  def do_dual_op(di)
    args = di.instruction.args
    dest_arg, src_arg = *args

    # emulating push
    #if dest_arg.kind_of?(CY16::IndirectMemref) and dest_arg.base.class == CY16::Reg then
    if dest_arg.kind_of?(Metasm::CY16::Memref) and not dest_arg.offset and
      dest_arg.base.class == Metasm::CY16::Reg then
      if dest_arg.base.i == 15 then
        puts "write instruction pre-decrements sp" if @verbose
        sp = rr(15)
        sr(15, sp - 2)
      end
    end

    # kludge
    unless src_arg
      if %w{ neg not }.include?(di.opcode.name)
        src_arg = Metasm::Expression[0]
      else
        raise di.opcode.name
      end
    end

    dest_addr, new_value, affected_flags =
      self.send( "do_#{di.opcode.name}", di, reduce_addr(dest_arg),
        reduce_value(dest_arg), reduce_value(src_arg) )

    wv(dest_addr, new_value) if dest_addr and new_value
    update_flags(new_value, affected_flags) unless affected_flags.empty?

     # emulating pop
    #if src_arg.kind_of?(CY16::IndirectMemref) and src_arg.base.class == CY16::Reg then
    if src_arg.kind_of?(Metasm::CY16::Memref) and not src_arg.offset and
      src_arg.base.class == Metasm::CY16::Reg then
      if src_arg.base.i == 15 then
        puts "read instruction post-increments sp" if @verbose
        sp = rr(15)
        sr(15, sp + 2)
      end
    end

    @pc = next_ins(di)
  end

  def do_single_op(di)
    do_dual_op(di)
  end

  def do_prog_control(di)
    args = di.instruction.args
    opname = di.opcode.name

    if opname == "ret" then
      do_ret(di)
    else
      dest = reduce_value(args[0])
      begin
        self.send("do_#{di.opcode.name}", di, dest)
      rescue Exception => e
        puts "#{di}"
        raise e
      end
    end  
  end

  def do_misc(di)
    self.send("do_#{di.opcode.name}", di)
    @pc = next_ins(di)
  end

  ## Utility functions

  def make_signed(val)
    val = val - (1 << BITLEN) if ((val > 0) and (msb(val) == 1))
    return val
  end

  def msb(v)
    v >> (BITLEN - 1)
  end

  def next_ins(di)
    @pc + di.bin_length
  end

  # http://teaching.idallen.com/dat2343/10f/notes/040_overflow.txt
  # http://coding.derkeiler.com/Archive/Assembler/alt.lang.asm/2007-01/msg01087.html
  def update_flags(v, flags)
    #show_flags
    if flags.include?(:z) then
      (v == 0) ? sz : cz
    end

    if flags.include?(:s) then
      (msb(v) == 1) ? ss : cs
    end
    #show_flags
  end

  def handle_autoinc(o)
    return unless o.kind_of?(Metasm::CY16::Memref)
    base = o.base

    if o.autoincr and base.class == Metasm::CY16::Reg then
        #puts "r#{base.i} += #{o.sz}"
        v = rr(base.i)
        sr(base.i, v + o.sz)
    end
  end

  def memref_to_addr(memref)
    addr = 0
    case memref.base
    when ::Fixnum          ; addr = memref.base
    when Metasm::CY16::Reg ; addr = rr(memref.base.i)
    when ::NilClass        ; # can be nil
    else                   ; raise "invalid argument: #{memref}"
    end

    case memref.offset
    when Metasm::Expression ; addr += memref.offset.rexpr
    when ::Fixnum           ; addr += memref.offset
    when ::NilClass         ; # can be nil
    else                    ; raise "invalid argument: #{memref}"
    end

    return addr
  end

  # Transform a value arg in its most simplest form
  def reduce_value(arg)
    case arg
    when Metasm::Expression
      v = arg.rexpr
      case v
      when Fixnum            ; v
      when /(sub|loc)_(.*)h/ ; $2.to_i(16) # kludgy
      else                   ; raise "invalid value: #{v}"
      end
    when Metasm::CY16::Reg, Metasm::CY16::Memref ; rv(arg)
    else                                         ; raise "invalid argument: #{arg}"
    end
  end

  # Transform an address arg in its most simplest form
  def reduce_addr(arg)
    # actually, it does nothing
    case arg
    when Metasm::CY16::Reg, Metasm::CY16::Memref ; arg # the destination register or memory reference
    else                                         ; raise "invalid argument: #{d}"
    end
  end

  ## Memory management (read/write) functions
  # Write value v at destination d (register or memory reference)
  def wv(d, v)
    case d
    when Metasm::CY16::Reg ; sr(d.i, v)
    when Metasm::CY16::Memref
      addr = memref_to_addr(d)
      case d.sz
      when 1 ; wb(addr, v)
      when 2 ; ww(addr, v)
      else   ; raise "invalid value: #{d.sz}"
      end
    else ; raise "invalid argument: #{d}"
    end
  end

  # Read value at destination d (register or memory reference)
  def rv(d)
    case d
    when Metasm::CY16::Reg ; rr(d.i)
    when Metasm::CY16::Memref
      addr = memref_to_addr(d)
      case d.sz
      when 1 ; rb(addr)
      when 2 ; rw(addr)
      else   ; raise "invalid value: #{d.sz}"
      end
    else ; raise "invalid argument: #{d}"
    end
  end

  # Set the register ri to the value v 
  
  def check_addr(addr, write = false)
    unless write
      @readable_segments.each do |s|
        return true if s.include?(addr)
      end
      puts "invalid read destination: #{addr.to_s(16)}"
      #gets
      return false
    end

    @writeable_segments.each do |s|
      return true if s.include?(addr)
    end
    #puts "invalid write destination: #{addr.to_s(16)}"
    #gets
    return false
  end

  def sr(i, v)
    newv = v & 0xffff
    puts("(sr) r#{i} <- 0x%x" % [ newv ]) if @verbose
    @gpr[i] = newv
  end

  # Return the value of the register ri
  def rr(i)
    v = @gpr[i] & 0xffff
    puts("(rr) r#{i} -> 0x%x" % [ v ]) if @verbose
    v
  end

  # Read in memory the word at address addr
  def rw(addr)
    # little-endianness handling
    v = (@mem.data[addr] & 0xff) | ((@mem.data[addr+1] & 0xff) << 8)
    puts("(rw) mem[0x%04x] -> %4.4x" % [ addr, v ]) if @verbose
    if [@base_addr, @base_addr+16].include?(addr)
      #gets
    end
    v
  end

  # Read in memory the byte at address addr
  def rb(addr)
    v = @mem.data[addr] & 0xff
    if [@base_addr, @base_addr+16].include?(addr)
    #  puts  "interesting read (rb) mem[0x%04x] -> %2.2x" % [ addr, v ]
    end
    v
  end

  # Write in memory the word v at the address addr
  def ww(addr, v)
    puts("(ww) mem[0x%04x] <- %4.4x" % [ addr , v ]) if @verbose
    check_addr(addr, true)
    @mem.data[addr] = v & 0xff
    @mem.data[addr + 1] = (v >> 8) & 0xff
  end

  # Write in memory the byte v at the address addr
  def wb(addr, v)
    puts("(wb) mem[0x%04x] <- %2.2x" % [ addr , v ]) if @verbose
    check_addr(addr, true)
    @mem.data[addr] = v & 0xff
  end

  def pushall_int
    (0..14).each do |i|
      push(rr(i))
    end
  end

  def popall_int
    (0..14).to_a.reverse.each do |i|
      sr(i, pop())
    end
  end

  def push(v)
    sp = rr(15)
    new_sp = sp - 2
    ww(new_sp, v)
    sr(15, new_sp)
  end

  def pop
    sp = rr(15)
    v = rw(sp)
    new_sp = sp + 2
    sr(15, new_sp)
    return v
  end
 
  ## opcodes handling

  # dual operand instructions
  def do_mov(di, dest_addr, dest_value, src_value)
    return [dest_addr, src_value, []]
  end

  def do_add(di, dest_addr, dest_value, src_value)
    new_value, c, o = @alu.add(dest_value, src_value, 0)
    new_value &= 0xffff
    (c == 1) ? sc : cc
    (o == 1) ? so : co

    return [dest_addr, new_value, [ :z, :s ]]   
  end

  def do_addc(di, dest_addr, dest_value, src_value)
    new_value, c, o = @alu.add(dest_value, src_value, gc)
    new_value &= 0xffff
    (c == 1) ? sc : cc
    (o == 1) ? so : co
    return [dest_addr, new_value, [ :z, :s ]]    
  end

  def do_sub(di, dest_addr, dest_value, src_value)
    new_value, c, o = @alu.sub(dest_value, src_value, 0)
    new_value &= 0xffff
    (c == 1) ? sc : cc
    (o == 1) ? so : co
    return [dest_addr, new_value, [ :z, :s ]]    
  end

  def do_subb(di, dest_addr, dest_value, src_value)
    new_value, c, o = @alu.sub(dest_value, src_value, gc)
    new_value &= 0xffff
    (c == 1) ? sc : cc
    (o == 1) ? so : co
    return [dest_addr, new_value, [ :z, :s ]]    
  end

  def do_cmp(di, dest_addr, dest_value, src_value)
    new_value, c, o = @alu.sub(dest_value, src_value, 0)
    (c == 1) ? sc : cc
    (o == 1) ? so : co
    return [nil, new_value, [ :z, :s ]]
  end

  def do_and(di, dest_addr, dest_value, src_value)
    new_value = dest_value & src_value
    return [dest_addr, new_value, [ :z, :s ]]
  end

  def do_test(di, dest_addr, dest_value, src_value)
    new_value = dest_value & src_value
    return [nil, new_value, [ :z, :s ]]
  end

  def do_or(di, dest_addr, dest_value, src_value)
    new_value = dest_value | src_value
    return [dest_addr, new_value, [ :z, :s ]]
  end

  def do_xor(di, dest_addr, dest_value, src_value)
    new_value = dest_value ^ src_value
    return [dest_addr, new_value, [ :z, :s ]]
  end

  # program control
  def do_ret(di)
    if rr(15) < @top_stack
      call_pc, call_addr, f, call_st = @trace.pop

      if @pc == 0x40fc then
        @trace.reverse.each do |pc, addr, ftmp, st|
          if addr == 0x44da then
            call_pc, call_addr, f, call_st = pc, addr, ftmp, st
            break
          end
        end
      end
      raise unless call_st
      raise unless call_pc == call_st.pc

      ret_st = save_state(di)
      if @test_gen
        @test_gen << [f, call_st, ret_st]
      end

      @pc = pop()
      puts("pc = #{@pc.to_s(16)}") if @verbose
    else
      @pc = nil
    end
  end

  def do_int(di, v)
    case v
    when 0x49
      pushall_int
      @pc = next_ins(di)
    when 0x4a
      popall_int
      @pc = next_ins(di)
    when 0x50
      susb1_send_int(di)
    when 0x51
      susb1_receive_int(di)
    when 0x59
      susb1_finish_int(di)
      @pc = next_ins(di)
    else
      #raise "int #{n} not implemented"
      puts "int #{n} not implemented"
      @pc = next_ins(di)
    end
  end

  def do_call(di, addr)
    # push on stack the next instruction
    puts("call : pushing %04x" % [ @pc + di.bin_length ]) if @verbose
    f = @functions[addr]
    raise "function not found for 0x#{addr.to_s(16)}" unless f

    #puts "0x%04x call 0x%04x\n" % [@pc, addr];
    @trace << [ @pc, addr, f, save_state(di) ]

    push(next_ins(di))
    @pc = addr 
  end

  # zero
  def do_jz(di, dest)
    @pc = (gz == 1) ? dest : next_ins(di)
  end

  # not zero
  def do_jnz(di, dest)
    @pc = (gz == 0) ? dest : next_ins(di)
  end

  # above
  def do_ja(di, dest)
    @pc = ( (gz == 0) && (gc == 0) ) ? dest : next_ins(di)
  end

  def do_jo(di, dest)
    @pc = (go == 1) ? dest : next_ins(di)
  end

  def do_jno(di, dest)
    @pc = (go == 0) ? dest : next_ins(di)
  end

  # carry
  def do_jc(di, dest)
    @pc = (gc == 1) ? dest : next_ins(di)
  end

  def do_jb(di, dest)
    do_jc(di, dest)
  end

  def do_js(di, dest)
    @pc = (gs == 1) ? dest : next_ins(di)
  end

  def do_jns(di, dest)
    @pc = (gs == 0) ? dest : next_ins(di)
  end

  # not carry
  def do_jnc(di, dest)
    @pc = (gc == 0) ? dest : next_ins(di)
  end

  def do_jae(di, dest)
    do_jnc(di, dest)
  end

  # below or equal / not above
  def do_jbe(di, dest)
    @pc = ( (gz == 1) || (gc == 1) ) ? dest : next_ins(di)
  end

  def do_jl(di, dest)
    @pc = ( go != gs ) ? dest : next_ins(di)
  end

  def do_jle(di, dest)
    @pc = ( ( go != gs ) || (gz == 1) ) ? dest : next_ins(di)
  end

  def do_jg(di, dest)
    @pc = ( (go == gs) && (gz == 0) ) ? dest : next_ins(di)
  end

  def do_jge(di, dest)
    @pc = ( go == gs ) ? dest : next_ins(di)
  end

  def do_jmp(di, dest)
    @pc = dest
  end

  # single operand instruction
  def do_addi(di, dest_addr, dest_value, param)
    new_value = @alu.add(dest_value, param, 0).first
    new_value &= 0xffff
    return [dest_addr, new_value, [ :z, :s ]]
  end

  def do_subi(di, dest_addr, dest_value, param)
    new_value = @alu.sub(dest_value, param, 0).first
    new_value &= 0xffff
    return [dest_addr, new_value, [ :z, :s ]]
  end

  def do_shl(di, dest_addr, dest_value, param)
    new_value = (dest_value << param)
    new_value &= 0xffff
    if param < 1 or param > 8
      raise "invalid shift value: #{param}"
    end
    # The C flag is set with the last bit shifted out of MSB.
    c = (dest_value >> (BITLEN - param)) & 1
    (c == 1) ? sc : cc
    return [dest_addr, new_value, [ :z, :s ]]
  end

  def do_shr(di, dest_addr, dest_value, param)
    new_value = (dest_value >> param)
    new_value &= 0xffff
    if param < 1 or param > 8
      raise "invalid shift value: #{param}"
    end
    # The C flag is set with the last bit shifted out of LSB.
    c = (dest_value >> (param - 1)) & 1
    (c == 1) ? sc : cc
    return [dest_addr, new_value, [ :z, :s ]]
  end

  def do_rol(di, dest_addr, dest_value, param)
    tmp = dest_value >> (BITLEN - param)
    new_value = ( (dest_value << param) | tmp )
    new_value &= 0xffff
    if param < 1 or param > 8
      raise "invalid shift value: #{param}"
    end
    c = (new_value & 1)
    (c == 1) ? sc : cc
    return [dest_addr, new_value, [ :z, :s ]]
  end

  def do_ror(di, dest_addr, dest_value, param)
    tmp = dest_value & ((1 << param) - 1)
    new_value = (dest_value >> param) | (tmp << (BITLEN - param) )
    new_value &= 0xffff
    if param < 1 or param > 8
      raise "invalid shift value: #{param}"
    end
    c = (dest_value >> (BITLEN - 1 - param) ) & 1
    (c == 1) ? sc : cc
    return [dest_addr, new_value, [ :z, :s ]]
  end

  def do_not(di, dest_addr, dest_value, useless)
    # one's complements
    new_value = dest_value ^ ((1 << BITLEN) - 1)
    return [dest_addr, new_value, [ :z, :s ]]
  end

  # misc instruction
  def do_stX(di)
    # undocumented instruction
    #sc
  end

  def do_clX(di)
  end

  def do_stc(di)
    sc
  end

  # interrupts
  def susb1_receive_int(di)
    # simulate successful transfer
    baddr = rr(8)
    addr = rw(baddr + 2)
    len  = rw(baddr + 4)
    callback_addr = rw(baddr + 6)

    #st = save_state(di)
    #puts st.memdump

    if client
      data =  @client.read(len).bytes.to_a
      pretty_data = data.map {|x| "%02x" % x}.join('')
      puts "[+] 0x%04x: recv(%s) (len = %d)" % [addr, pretty_data, len]
      @mem.data[addr..addr+len-1] = data
    end

    #if @test_gen
    #  @test_gen.curf.puts 
    #  p = addr
    #  @mem.data[addr..addr+len-1].each do |b|
    #    @test_gen.curf.puts "    sb(0x%04x, 0x%02x);" % [p, b]
    #    p += 1;
    #  end
    #  @test_gen.curf.puts
    #end

    do_call(di, callback_addr)

    # simulate successful operation
    #sr(0, 0)
    #ww(baddr, 0)
    #ww(baddr + 2, addr + len)
    #ww(baddr + 4, 0)

    #puts("call : pushing %04x" % [ @pc + di.bin_length ]) if @verbose
    #push(@pc + di.bin_length)
    #@pc = callback_addr
  end

  def susb1_send_int(di)
    # simulate successful transfer
    baddr = rr(8)
    addr = rw(baddr + 2)
    len  = rw(baddr + 4)
    callback_addr = rw(baddr + 6)

    data = @mem.data[addr..addr+len-1]
    pretty_data = data.map {|x| "%02x" % x}.join('')
    puts "[+] 0x%04x: send(%s) (len = %d)" % [addr, pretty_data, len]

    if @client then
      @client.send(data.pack('C*'), 0)
    end

    do_call(di, callback_addr)

    #sr(0, 0)
    #ww(baddr, 0)
    #ww(baddr + 2, addr + len)
    #ww(baddr + 4, 0)

    #push(@pc + di.bin_length)
    #@pc = callback_addr
  end

  def susb1_finish_int(di)
    #puts "[+] sub1_finish_int"
    #st = save_state(di)
    #puts st.memdump
    # R9 = DEV0_EP0_CTL_REG
    sr(9, 0x200)
  end

end

end # end of CY16
