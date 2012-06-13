module CY16

class Loader

  def initialize(file, offset, base_addr)
    @file = File.expand_path(file)
    @offset = offset
    @base_addr = base_addr
  end

  def handle_relocs(data)
    raise unless @sc and data
    binary = @sc.unpack('v*')
    relocs = data.unpack('v*')
    relocs.each do |r|
      raise unless (r % 2) == 0
      before = binary[r / 2]
      binary[r / 2] = before + @base_addr
    end
    @sc = binary.pack('v*')
  end

  def handle_bios_opcode(opcode, data)
    case opcode
    when 2 # Write Interrupt Service Routine
      interrupt = data[0]
      puts "[+] write interrupt #{interrupt}"
      @sc = data[1..-1]
    when 3 # Fix-up (relocate) ISR code
      interrupt = data[0]
      puts "[+] fix-up (relocate) ISR #{interrupt}"
      raise unless @sc
      handle_relocs(data[1..-1])
    when 6 # Call interrupt
      interrupt = data[0]
      puts "[+] call interrupt #{interrupt}"
      raise unless @sc
    end
  end

  def load_rom
    fh = File.open(@file, "rb")
    fh.seek(@offset, IO::SEEK_SET)
    while( fh.read(2).unpack('v').first == 0xc3b6 ) do
      data_size = fh.read(2).unpack('v').first
      bios_opcode = fh.read(1).bytes.first
      data = fh.read(data_size)
      handle_bios_opcode(bios_opcode, data)
    end
    raise unless @sc
    return @sc
  end

end

end # end of CY16
