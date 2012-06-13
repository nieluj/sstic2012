class Fixnum
  def bit(idx)
    (self >> idx) & 1
  end

  def to_bit_array(bitlen = 16)
    a = []
    0.upto(bitlen-1) do |idx|
      a << bit(idx)
    end
    return a
  end

end

class Array
  def to_fixnum(bitlen = 16)
    r = 0
    self.each_with_index do |bit, pos|
      r |= (bit << pos)
    end
    return r
  end
end

module CY16

class ALU
  BITLEN = 16

  def sign_bit(a)
    a[BITLEN-1]
  end

  @@add_table = [ [ [], [] ], [ [], [] ] ]
  #           v1 v2 c     r  cr
  @@add_table[0][0][0] = [0, 0]
  @@add_table[0][1][0] = [1, 0]
  @@add_table[1][0][0] = [1, 0]
  @@add_table[1][1][0] = [0, 1]
  @@add_table[0][0][1] = [1, 0]
  @@add_table[0][1][1] = [0, 1]
  @@add_table[1][0][1] = [0, 1]
  @@add_table[1][1][1] = [1, 1]

  def add(v1, v2, carry = 0)
    overflow = 0
    a1 = v1.to_bit_array(BITLEN)
    a2 = v2.to_bit_array(BITLEN)
    ret, carry = do_op(@@add_table, a1, a2, carry)

    # pos + pos => neg
    if sign_bit(a1) == 0 and sign_bit(a2) == 0 and
      sign_bit(ret) == 1 then
      overflow = 1
    end

    # neg + neg => pos
    if sign_bit(a1) == 1 and sign_bit(a2) == 1 and
      sign_bit(ret) == 0 then
      overflow = 1
    end

    return [ret.to_fixnum(BITLEN), carry, overflow]
  end

  @@sub_table = [ [ [], [] ], [ [], [] ]  ]
  #           v1 v2 b     r  br
  @@sub_table[0][0][0] = [0, 0]
  @@sub_table[0][1][0] = [1, 1]
  @@sub_table[1][0][0] = [1, 0]
  @@sub_table[1][1][0] = [0, 0]
  @@sub_table[0][0][1] = [1, 1]
  @@sub_table[0][1][1] = [0, 1]
  @@sub_table[1][0][1] = [0, 0]
  @@sub_table[1][1][1] = [1, 1]

  def sub(v1, v2, borrow = 0)
    overflow = 0
    a1 = v1.to_bit_array(BITLEN)
    a2 = v2.to_bit_array(BITLEN)
    ret, borrow = do_op(@@sub_table, a1, a2, borrow)

    # neg + neg => pos <=> neg - (pos) => pos
    if sign_bit(a1) == 1 and sign_bit(a2) == 0 and
      sign_bit(ret) == 0 then
      overflow = 1
    end

    # pos + pos => neg <=> pos - (neg) => neg
    if sign_bit(a1) == 0 and sign_bit(a2) == 1 and
      sign_bit(ret) == 1 then
      overflow = 1
    end

    return [ret.to_fixnum(BITLEN), borrow, overflow]
  end

  def do_op(table, a1, a2, carry)
    ret = []

    0.upto(BITLEN-1) do |i|
      r, carry = table[a1[i]][a2[i]][carry]
      ret << r
    end

    return [ret, carry]
  end
end

end # end of CY16
