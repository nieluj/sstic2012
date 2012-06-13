#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path("~/git/hub/m/etasm")

require 'pp'
require 'cy16/metaemul'
require 'cy16/function'
require 'cy16/gui'
require 'cy16/fakeclient'
require 'functions'

TRACE = "~/git/hub/s/stic2012/part2a_rom/data/traces/trace-20120425.txt"
BIN_FILE = "~/git/hub/s/stic2012/input/ssticrypt"
INIT_ROM_OFFSET   = 0x475b4
INIT_ROM_LEN      = 0x44
STAGE2_ROM_OFFSET = 0x4772c
STAGE2_ROM_LEN    = 0xa76
STACK_BASE        = 0x5000
REMAP_ADDR        = 0x4000

emul = CY16::Emulator.new(STACK_BASE, REMAP_ADDR)

emul.add_funcs *$functions
emul.load_file(File.expand_path(BIN_FILE), STAGE2_ROM_OFFSET)

fc = CY16::FakeClient.new(File.expand_path(TRACE))
emul.client = fc

app = Qt::Application.new(ARGV)
widget = CY16::EmulWidget.new(app)

# simulate receiving data
emul.gpr[8] = 0x300
emul.gpr[9] = 0x200
emul.wb(0x301, 0x51)
emul.ww(0x302, fc.off_src)
emul.ww(0x304, 1)
emul.ww(0x306, 16)
emul.execute(0x76 + REMAP_ADDR, true, true)

emul.saved_states.each do |addr, st|
  widget.add_saved_state(addr, st)
end

widget.show
app.exec
