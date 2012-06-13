require 'pp'

class String
  def hex_to_bin
    self.split(/\s/).map {|x| x.to_i(16) }.pack('C*')
  end

  def bin_to_hex
    self.unpack('n*').map {|x| "%04x" % x}.join(' ')
  end
end

module CY16
  class FakeClient
    TRACE = File.expand_path("~/git/sstic2012/part2/rom/traces/trace-20120425.txt")

    def initialize(trace = TRACE)
      @trace = TRACE
      @recv_data = []
      @send_data = []
      @last_sent = nil
      raise unless File.exists?(@trace)
      parse_trace
    end

    def parse_trace
      File.open(@trace, "r").each_line do |line|
        case line.chomp
        when /usb_control_msg\(0x\h+, 40, 51, (\h+), 1, 0x\h+, 10, \h+\): ((\h{2,2}\s){16,16})/
          offset = $1.to_i(16)
          @recv_data << [offset, $2.hex_to_bin]
        when /usb_control_msg\(0x\h+, c0, 56, (\h+), 0, 0x\h+, 14, \h+\): ((\h{2,2}\s){20,20})/
          offset = $1.to_i(16)
          @send_data << [offset, $2.hex_to_bin]
        else
          puts "not parsed: #{line.chomp}"
        end
      end
    end

    def read(len)
      raise "bad len: #{len}" unless len == 16
      return @recv_data.shift.last
    end

    def send(byte_array, v)
      data = @send_data.shift.last
      raise "#{byte_array.bin_to_hex} != #{data.bin_to_hex}" unless byte_array == data
    end

    def off_src
      @recv_data.first.first
    end

    def data
      @recv_data.first.last
    end

    def has_data?
      not @recv_data.empty?
    end

    def pretty_print
      @recv_data.each_with_index do |rd, i|
        sd = @send_data[i]
        puts ("[%03d] #{rd[1].bin_to_hex} => #{sd[1].bin_to_hex}" % i)
      end
    end

  end
end
