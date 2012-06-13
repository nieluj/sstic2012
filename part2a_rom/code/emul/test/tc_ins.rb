lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift lib_path
$LOAD_PATH.unshift File.expand_path("~/git/hub/m/etasm")

require 'test/unit'
require 'cy16/metaemul'

class TC_Instructions < Test::Unit::TestCase
  def setup
    @emul = CY16::Emulator.new
  end

  def test_do_not
    ret = @emul.do_not(nil, 0x4000, 0, nil)
    assert_equal([0x4000, 0xffff, [:z, :s]], ret)

    @emul.update_flags(0xffff, [:z, :s])
    assert_equal(0, @emul.gz)
    assert_equal(1, @emul.gs)

    ret = @emul.do_not(nil, 0x4000, 0xffff, nil)
    assert_equal([0x4000, 0, [:z, :s]], ret)

    @emul.update_flags(0, [:z, :s])
    assert_equal(1, @emul.gz)
    assert_equal(0, @emul.gs)

    ret = @emul.do_not(nil, 0x4000, 0b0101_0101_0101_0101, nil)
    assert_equal([0x4000, 0b1010_1010_1010_1010, [:z, :s]], ret)

    @emul.update_flags(0b1010_1010_1010_1010, [:z, :s])
    assert_equal(0, @emul.gz)
    assert_equal(1, @emul.gs)
  end

  def test_do_add
    ret = @emul.do_add(nil, 0x4000, 0, 0)
    assert_equal([0x4000, 0, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)

    ret = @emul.do_add(nil, 0x4000, 0, 1)
    assert_equal([0x4000, 1, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)

    ret = @emul.do_add(nil, 0x4000, 1, 0)
    assert_equal([0x4000, 1, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)

    ret = @emul.do_add(nil, 0x4000, 32000, 32000)
    assert_equal([0x4000, 64000, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 1)

    ret = @emul.do_add(nil, 0x4000, 0xffff, 1)
    assert_equal([0x4000, 0, [:z, :s]], ret)
    assert_equal(@emul.gc, 1)
    assert_equal(@emul.go, 0)

    ret = @emul.do_add(nil, 0x4000, 0xffff, 0x13)
    assert_equal([0x4000, 0x12, [:z, :s]], ret)
    @emul.update_flags(ret[1], ret[2])
    assert_equal(@emul.gz, 0)
    assert_equal(@emul.gc, 1)
    assert_equal(@emul.go, 0)
    assert_equal(@emul.gs, 0)
  end

  def test_do_rol
    ret = @emul.do_rol(nil, 0x4000, 0b0101_0101_0101_0101, 1)
    assert_equal([0x4000, 0b1010_1010_1010_1010, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)

    ret = @emul.do_rol(nil, 0x4000, 0b0101_0101_0101_0101, 2)
    assert_equal([0x4000, 0b0101_0101_0101_0101, [:z, :s]], ret)
    assert_equal(@emul.gc, 1)
    assert_equal(@emul.go, 0)

    ret = @emul.do_rol(nil, 0x4000, 0b0101_0101_0101_0101, 3)
    assert_equal([0x4000, 0b1010_1010_1010_1010, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)
  end

  def test_do_shl
    ret = @emul.do_shl(nil, 0x4000, 0b0101_0101_0101_0101, 1)
    assert_equal([0x4000, 0b1010_1010_1010_1010, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)

    ret = @emul.do_shl(nil, 0x4000, 0b0101_0101_0101_0101, 2)
    assert_equal([0x4000, 0b0101_0101_0101_0100, [:z, :s]], ret)
    assert_equal(@emul.gc, 1)
    assert_equal(@emul.go, 0)

    ret = @emul.do_shl(nil, 0x4000, 0b0101_0101_0101_0101, 3)
    assert_equal([0x4000, 0b1010_1010_1010_1000, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)
  end

  def test_do_ror
    ret = @emul.do_ror(nil, 0x4000, 0b0101_0101_0101_0101, 1)
    assert_equal([0x4000, 0b1010_1010_1010_1010, [:z, :s]], ret)
    assert_equal(@emul.gc, 1)
    assert_equal(@emul.go, 0)

    ret = @emul.do_ror(nil, 0x4000, 0b0101_0101_0101_0101, 2)
    assert_equal([0x4000, 0b0101_0101_0101_0101, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)

    ret = @emul.do_ror(nil, 0x4000, 0b0101_0101_0101_0101, 3)
    assert_equal([0x4000, 0b1010_1010_1010_1010, [:z, :s]], ret)
    assert_equal(@emul.gc, 1)
    assert_equal(@emul.go, 0)
  end

  def test_do_shr
    ret = @emul.do_shr(nil, 0x4000, 0b0101_0101_0101_0101, 1)
    assert_equal([0x4000, 0b0010_1010_1010_1010, [:z, :s]], ret)
    assert_equal(@emul.gc, 1)
    assert_equal(@emul.go, 0)

    ret = @emul.do_shr(nil, 0x4000, 0b0101_0101_0101_0101, 2)
    assert_equal([0x4000, 0b0001_0101_0101_0101, [:z, :s]], ret)
    assert_equal(@emul.gc, 0)
    assert_equal(@emul.go, 0)

    ret = @emul.do_shr(nil, 0x4000, 0b0101_0101_0101_0101, 3)
    assert_equal([0x4000, 0b0000_1010_1010_1010, [:z, :s]], ret)
    assert_equal(@emul.gc, 1)
    assert_equal(@emul.go, 0)
  end

  def test_do_subi
    ret = @emul.do_subi(nil, 0x4000, 0, 1)
    assert_equal([0x4000, 0xffff, [:z, :s]], ret)
    @emul.update_flags(ret[1], ret[2])
    assert_equal(@emul.gz, 0)
    assert_equal(@emul.gs, 1)
  end

  def teardown
    @emul = nil
  end
end

