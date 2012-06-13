lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift lib_path

require 'test/unit'
require 'cy16/alu'

class TC_ALU < Test::Unit::TestCase
  def setup
    @alu = CY16::ALU.new
  end
 
  def test_add
    assert_equal([0b0000_0000_0000_0001, 0, 0],
      @alu.add(0b0000_0000_0000_0000, 0b0000_0000_0000_0001, 0))
    
    assert_equal([0b0000_0000_0000_0000, 1, 1],
      @alu.add(0b1000_0000_0000_0000, 0b1000_0000_0000_0000, 0))
 
    assert_equal([0b1111_1111_1111_1110, 1, 0],
      @alu.add(0b1111_1111_1111_1111, 0b1111_1111_1111_1111, 0))

    assert_equal([0b1111_1010_0000_0000, 0, 1],
      @alu.add(0b0111_1101_0000_0000, 0b0111_1101_0000_0000, 0))
    
   assert_equal([0b0111_1010_0000_0000, 1, 0],
      @alu.add(0b1111_1101_0000_0000, 0b0111_1101_0000_0000, 0))
  end

  def test_add_with_carry
    assert_equal([0b0000_0000_0000_0010, 0, 0],
      @alu.add(0b0000_0000_0000_0000, 0b0000_0000_0000_0001, 1))
    
    assert_equal([0b0000_0000_0000_0001, 1, 1],
      @alu.add(0b1000_0000_0000_0000, 0b1000_0000_0000_0000, 1))
    
    assert_equal([0b1111_1111_1111_1111, 1, 0],
      @alu.add(0b1111_1111_1111_1111, 0b1111_1111_1111_1111, 1))
  end

  # fixme
  def test_sub
    assert_equal([1, 0, 0],
      @alu.sub(2, 1, 0))
  
    assert_equal([0xffff, 1, 0],
      @alu.sub(0, 1, 0))

    assert_equal([0b0111_1111_1111_1111, 0, 1],
      @alu.sub(1 << 15, 1, 0))
    
    assert_equal([0, 0, 0],
      @alu.sub(0x51, 0x51, 0))
  end

  def teardown
    @alu = nil
  end
end

