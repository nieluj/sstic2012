#!/usr/bin/env ruby

lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift lib_path
$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path("~/git/hub/m/etasm")

require 'pp'
require 'cy16/metaemul'
require 'cy16/function'
require 'functions'
require 'socket'

BIN_FILE = "~/git/hub/s/stic2012/input/ssticrypt"
INIT_ROM_OFFSET   = 0x475b4
INIT_ROM_LEN      = 0x44
STAGE2_ROM_OFFSET = 0x4772c
STAGE2_ROM_LEN    = 0xa76
REMAP_ADDR        = 0x4000

emul = CY16::Emulator.new(0x5000, REMAP_ADDR)

emul.add_funcs *$functions
emul.load_file(File.expand_path(BIN_FILE), STAGE2_ROM_OFFSET)

server = TCPServer.new(31337)

loop do
  client = server.accept
  puts "new client"

  while h = client.read(7) do
    a = h.bytes.to_a
    request = a[0]
    value   = a[1] | (a[2] << 8)
    index   = a[3] | (a[4] << 8)
    size    = a[5] | (a[6] << 8)
    puts "request = 0x%x, value = 0x%x, index = 0x%x, size = 0x%x" % [request, value, index, size]
    case request
    when 0x51
      puts "handling read request"
      saved_gpr = emul.gpr.dup
      emul.gpr[8] = 0x300
      emul.gpr[9] = 0x200
      emul.wb(0x301, request)
      emul.ww(0x302, value)
      emul.ww(0x304, index)
      emul.ww(0x306, size)
      emul.client = client
      emul.execute(0x76 + REMAP_ADDR, false, false)
      emul.gpr = saved_gpr
      puts "end of execution"
    when 0x56
      puts "handling send request"
      saved_gpr = emul.gpr.dup
      emul.gpr[8] = 0x300
      emul.gpr[9] = 0x200
      emul.wb(0x301, request)
      emul.ww(0x302, value)
      emul.ww(0x304, index)
      emul.ww(0x306, size)
      emul.client = client
      emul.execute(0x76 + REMAP_ADDR, false , false)
      emul.gpr = saved_gpr
      puts "end of execution"
      #puts "sending #{ret.map {|x| x.to_s(16)}}"
      #puts ret.size
      #client.send(ret.pack('C*'), 0)
    end
  end

  client.close
end
