#!/usr/bin/env ruby

layers_len = [ 0x65a, 0xee2, 0x6e3 ]

blobs = []
blobs << [ 0x475b4, "init_rom", 0x44 ]
blobs << [ 0x4772c, "stage2_rom", 0xa76 ]
blobs << [ 0x47708, "blah", 0x20  ]
blobs << [ 0x475fc, "blob", 0x100 ]
blobs << [ 0x4888c, "layer1", 0x65a ]
blobs << [ 0x48ee8, "layer2", 0xee2 ]
blobs << [ 0x481a8, "layer3", 0x6e3 ]

f = File.open(ARGV.shift, "rb")

blobs.each do |offset, fname, len|
  f.seek(offset, IO::SEEK_SET)
  File.open(fname, "wb") do |fo|
    fo.write(f.read(len))
  end
end
