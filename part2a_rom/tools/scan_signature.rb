#!/usr/bin/env ruby

input = ARGV.shift

basename = File.basename(input)
dirname = File.dirname(input)

count = 0
File.open(input, "rb") do |fi|
  while s = fi.read(2)
    magic = s.unpack('v').first
    raise unless magic == 0xc3b6
    size = fi.read(2).unpack('v').first
    opcode = fi.read(1).unpack('c').first
    interrupt = fi.read(1).unpack('c').first
    data = fi.read(size-1)
    puts "scan record found: #{opcode}, #{size}"
    output_basename = "#{basename}_scan_record_#{count}"
    File.open(File.join(dirname, output_basename), "wb") do |fo|
      fo.write(data)
    end
    count += 1
  end

end

