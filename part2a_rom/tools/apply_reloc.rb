#!/usr/bin/env ruby

MAP_ADDR = 0x4000

binary = File.open(ARGV.shift, "rb").read.unpack('S*')
relocs = File.open(ARGV.shift, "rb").read.unpack('S*')
out = File.open(ARGV.shift, "wb")

relocs.each do |r|
  raise unless (r % 2) == 0
  before = binary[r / 2]
  puts "%04x: %04x -> %04x" % [ r, before, before + MAP_ADDR ]
  binary[r / 2] = before + MAP_ADDR
end

out.write( binary.pack('S*'))
out.close
