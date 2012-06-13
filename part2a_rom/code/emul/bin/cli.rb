#!/usr/bin/env ruby

lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift lib_path
$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path("~/git/hub/m/etasm")

require 'pp'
require 'cy16/metaemul'
require 'cy16/function'
require 'cy16/fakeclient'
require 'cy16/debugger'
require 'testgenerator'
require 'functions'

TRACE = "~/git/hub/s/stic2012/part2a_rom/data/traces/trace-20120425.txt"
BIN_FILE = "~/git/hub/s/stic2012/input/ssticrypt"
INIT_ROM_OFFSET   = 0x475b4
INIT_ROM_LEN      = 0x44
STAGE2_ROM_OFFSET = 0x4772c
STAGE2_ROM_LEN    = 0xa76
REMAP_ADDR        = 0x4000

gen_test = false
debug = true

emul = CY16::Emulator.new(0x5000, REMAP_ADDR)

emul.add_funcs *$functions
emul.load_file(File.expand_path(BIN_FILE), STAGE2_ROM_OFFSET)

fc = CY16::FakeClient.new(File.expand_path(TRACE))

tg = nil
if gen_test
  tg = TestGenerator.new("~/git/hub/s/stic2012/part2a_rom/code/reverse_ssticrypt/unit_tests.c")
end

emul.client = fc

dbg = nil
dbg = CY16::Debugger.new if debug

target_data = "5329f31fb21925f94b887be03f64324b".scan(/..../).map {|x| x.to_i(16)}.pack('n*')
target_offset = 0xf9f0

finaltg = nil
count = 1
while fc.has_data?
  #puts "[#{count}] target = #{target_data.bin_to_hex}, client = #{fc.data.bin_to_hex}"
  count +=2
  emul.gpr[8] = 0x300
  emul.gpr[9] = 0x200
  emul.wb(0x301, 0x51)
  emul.ww(0x302, fc.off_src)
  emul.ww(0x304, 1)
  emul.ww(0x306, 16)

  if dbg
    #if fc.data == target_data and fc.off_src == target_offset
    #if fc.data == target_data
      dbg.break_at(0x76 + REMAP_ADDR)
    #end
  end

  #tg.start_new_file(fc.data, fc.off_src) if gen_test
  if gen_test
    tg.data = fc.data
    tg.offset = fc.off_src
  end

  unless finaltg
    finaltg = (fc.data == target_data) ? tg : nil
  end

  if finaltg
    puts "generating tests!"
  end
  ret = emul.execute(0x76 + REMAP_ADDR, false, false, finaltg, dbg)
  break unless ret
  #tg.close_current_file if gen_test

  emul.gpr[8] = 0x300
  emul.gpr[9] = 0x200
  emul.wb(0x301, 0x56)
  emul.ww(0x302, 0)
  emul.ww(0x304, 0)
  emul.ww(0x306, 20)
  emul.mem.data[0x301] = 0x56
  ret = emul.execute(0x76 + REMAP_ADDR, false, false, finaltg, nil)
  break unless ret
  if dbg
    dbg.del_breakpoint(0x76 + REMAP_ADDR)
  end
  if finaltg and count > 1560
    break
  end
end

tg.generate if gen_test
