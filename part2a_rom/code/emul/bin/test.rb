#!/usr/bin/env ruby

lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift lib_path

require 'pp'
require 'cy16/fakeclient'

fc = CY16::FakeClient.new

fc.pretty_print
