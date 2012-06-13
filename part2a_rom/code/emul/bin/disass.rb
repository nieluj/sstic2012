#!/usr/bin/env ruby

lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift lib_path
$LOAD_PATH.unshift File.expand_path("~/git/github/metasm")

require 'pp'
require 'metasm'
require 'metasm/cpu/cy16'
include Metasm

require 'loader'
require 'hexdump'

BIN_FILE = "~/git/dedibox/sstic2012/input/ssticrypt"
INIT_ROM_OFFSET   = 0x475b4
INIT_ROM_LEN      = 0x44
STAGE2_ROM_OFFSET = 0x4772c
STAGE2_ROM_LEN    = 0xa76
REMAP_ADDR        = 0x4000
ENTRY_POINTS = [ 0x0, 0x76, 0xf6, 0xe8 ]

loader = Loader.new(BIN_FILE, STAGE2_ROM_OFFSET, REMAP_ADDR)
opcodes = loader.load_rom
#opcodes.hexdump

File.open("/tmp/out", "wb") do |fh|
  fh.write opcodes
end


cpu = CY16.new
disas = Metasm::Shellcode.decode(opcodes, cpu).disassembler
disas.rebase(REMAP_ADDR)

code = {}
disas.callback_newinstr = proc { |di|
  code[di.address] = di
  puts di
  di
}
ep = ENTRY_POINTS.map {|e| e + REMAP_ADDR }

puts "init"
disas.disassemble_fast_deep(0 + REMAP_ADDR)
puts

puts "int susb vendor"
disas.disassemble_fast_deep(0x76 + REMAP_ADDR)
puts

puts "int 0x51 callback"
disas.disassemble_fast_deep(0xf6 + REMAP_ADDR)
puts

puts "int 0x56 callback"
disas.disassemble_fast_deep(0xe8 + REMAP_ADDR)
puts

puts "sorted code"
code.sort.each do |k, v|
  puts v
end
