#!/usr/bin/env ruby
# vim: set noet ts=2 sw=2

require 'pp'
require 'optparse'
require 'erb'

class Fixnum
	def to_dest ; to_s ; end
	def to_src ; to_s ; end
	def to_value ; to_s ; end
end

module VM
	class Instruction

		@@registry = []

		class << self
			def register(opcode, klass)
				@@registry[opcode] = klass
			end

			def factory(opcode, pc, cond, condbits, uf)
				k = @@registry[opcode]
				raise "invalid opcode: #{opcode}" unless k
				return k.new(opcode, pc, cond, condbits, uf)
			end
		end

		OPCODES_STRINGS = %w[ and or neg shift mov jmp5 jmp6 jmp ]
		COND_STRINGS = %w[ z nz c nc s ns o no a be g ge l le  ]

		attr_reader :pc, :cond, :condbits, :uf
		def initialize(opcode, pc, cond, condbits, uf)
			@opcode = opcode
			@pc = pc
			@cond = cond
			@condbits = condbits
			@uf = uf
			@args = []
		end

		def cond_s
			(@cond == 0) ? "COND0" : "COND1"
		end

		def uf_s
			(@uf == 0) ? "NO_UF" : "DO_UF"
		end

		def <<(arg)
			@args << arg
		end

		def pc_to_a
			addr_to_pc(@pc)
		end

		def addr_to_pc(addr)
			nbits = addr & 7
			nbytes = (addr >> 3) & 0x1fff
			return [nbytes, nbits]
		end

		def addr_to_pc_string(addr)
			"%04d:%d" % addr_to_pc(addr)
		end

		def calc_cond_bits
			cbits = @condbits
			if @cond == 0
				cbits >>= 4;
			end
			cbits &= 0xf;
			return cbits
		end

		def cond_to_s
			cbits = calc_cond_bits
			if cbits <= 13
				return COND_STRINGS[cbits]
			else
				nil
			end
		end

		def cond_var
			cbits = calc_cond_bits
			s = cond_to_s
			case s
			when "z"
				"z#{@cond} == 1"
			when "nz"
				"z#{@cond} == 0"
			when "c"
				"c#{@cond} == 1"
			when "nc"
				"c#{@cond} == 0"
			else
				"codeme: #{s}"
			end
		end

		def opcode_to_s
			OPCODES_STRINGS[@opcode]
		end

		def to_s
			pcs = addr_to_pc_string(@pc)
			s = "[#{pcs}][c=#{@cond}][uf=#{@uf}] "
			s << opcode_to_s << " "

			cbits = calc_cond_bits

			if cbits <= 14
				s << COND_STRINGS[cbits] << " "
			end

			return s
		end

		def to_c
			s = ""
			if cond_to_s then
				s << "if (#{cond_var})\n\t\t"
			end
			return s
		end

	end

	class InsDualOp < Instruction
		def to_s
			super << @args[0].to_dest << ", " << @args[1].to_src
		end
	end

	class InsSingleOp < Instruction
		def to_s
			super << @args[0].to_dest
		end
	end

	class InsAnd < InsDualOp
		register(0, self)

		def to_c
			s = super
			dest, src = @args[0], @args[1]
			case dest
			when OpReg
				s << "#{dest} = and(#{cond_s}, #{uf_s}, #{dest}, #{src.to_value});"
			when Memref
				s << "andw(#{cond_s}, #{uf_s}, #{dest.to_addr}, #{src.to_value});"
			when OpObf
				s << "ando(#{cond_s}, #{uf_s}, #{dest.to_addr}, r#{dest.reg}, 0x#{dest.v.to_s(16)}, #{src.to_value});"
			end
			return s
		end

	end

	class InsOr < InsDualOp
		register(1, self)

		def to_c
			s = super
			dest, src = @args[0], @args[1]
			case dest
			when OpReg
				s << "#{dest} = or(#{cond_s}, #{uf_s}, #{dest}, #{src.to_value});"
			when Memref
				s << "orw(#{cond_s}, #{uf_s}, #{dest.to_addr}, #{src.to_value});"
			when OpObf
				s << "oro(#{cond_s}, #{uf_s}, #{dest.to_addr}, r#{dest.reg}, 0x#{dest.v.to_s(16)}, #{src.to_value});"
			end
			return s
		end
	end

	class InsNeg < InsSingleOp
		register(2, self)

		def to_c
			s = super
			dest = @args[0]
			case dest
			when OpReg
				s << "#{dest} = neg(#{cond_s}, #{uf_s}, #{dest});"
			when Memref
				s << "negw(#{cond_s}, #{uf_s}, #{dest.to_addr});"
			when OpObf
				s << "nego(#{cond_s}, #{uf_s}, #{dest.to_addr}, r#{dest.reg}, 0x#{dest.v.to_s(16)});"
			end
			return s
		end
	end

	class InsShift < InsDualOp
		register(3, self)

		def left?
			@args[2] == 0
		end

		def right?
			@args[2] == 1
		end

		def dir
			left? ? "left" : "right"
		end

		def opcode_to_s
			"shift " << dir
		end

		def to_c
			s = super
			dest, src = @args[0], @args[1]
			case dest
			when OpReg
				s << "#{dest} = shift(#{dir.upcase}, #{cond_s}, #{uf_s}, #{dest}, #{src.to_value});"
			when Memref
				s << "shiftw(#{dir.upcase}, #{cond_s}, #{uf_s}, #{dest.to_addr}, #{src.to_value});"
			when OpObf
				s << "shifto(#{dir.upcase}, #{cond_s}, #{uf_s}, #{dest.to_addr}, r#{dest.reg}, 0x#{dest.v.to_s(16)}, #{src.to_value});"
			end
			return s
		end
	end

	class InsMov < InsDualOp
		register(4, self)

		def to_c
			s = ""
			if cond_to_s then
				s << "if (#{cond_var})\n\t\t"
			end
			dest, src = @args[0], @args[1]
			case dest
			when OpReg
				s << "#{dest} = #{src.to_value};"
			when Memref
				s << "sw(#{dest.to_addr}, #{src.to_value});"
			when OpObf
				s << "swo(#{dest.to_addr}, r#{dest.reg}, 0x#{dest.v.to_s(16)}, #{src.to_value});"
			end
			return s
		end
	end

	class InsJmp < Instruction
		register(7, self)

		# TODO : clean this
		def next_pc
			cbytes, cbits = addr_to_pc(@args.last)
			nbytes, nbits, op = nil, nil, nil

			r12, r10 = @args[0,2]

			if r12 == 0 then
				op = @args[2]
				if not op.instance_of?(VM::OpImm)
					op.value, r10 = addr_to_pc(op.value)
				end
			end

			if @opcode == 6
				raise "code me!"
			end

			if r12 != 0 then
				r11 = r12 & 0x20
				r12 &= 0x1f
				if r11 == 0 then
					nbytes = cbytes
					nbytes += ( r12 + ((cbits + r10) >> 3) & 0x1fff)
					nbits = (cbits + r10) & 7
				else
					nbytes = cbytes - r12
					nbits = cbits
					if cbits < r10 then
						nbytes -= 1
						nbits += 8
					end
					nbits -= r10
				end
			else
				nbytes = op.value
				nbits = r10
			end
			return [nbytes, nbits]
		end

		def to_s
			super << ("%04d:%d" % next_pc)
		end

		def to_c
			super << "goto loc_%04d_%d;" % next_pc
		end
	end

	class Operand
		@@registry = []

		class << self
			def register(code, klass)
				@@registry[code] = klass
			end

			def factory(code, *args)
				k = @@registry[code]
				raise "invalid operand code: #{code}" unless k
				return k.new(*args)
			end
		end

		def to_dest ; to_s ; end
		def to_src ; to_s ; end
		def to_value ; to_s ; end
	end

	class OpReg < Operand
		register(0, self)

		attr_reader :reg
		def initialize(reg)
			@reg = reg
		end

		def to_s
			"r#{@reg}"
		end
	end

	class OpImm < Operand
		register(1, self)

		attr_reader :value, :size
		def initialize(value, size)
			@value = value
			@size = size
		end

		def to_s
			if @size == 0
				"0x%02x" % [ @value & 0xff ]
			else
				"0x%04x" % [ @value ]
			end
		end
	end

	class Memref < Operand
		register(2, self)

		def to_value
			"rw(" << to_addr << ")"
		end
	end

	class OpObf < Operand
		register(3, self)

		attr_reader :addr, :reg, :v, :size
		def initialize(addr, reg, v, size)
			@addr = addr
			@reg = reg
			@v = v
			@size = size
		end

		def to_s
			"obf(0x%x, r%d, 0x%x)" % [@addr, @reg, @v]
		end

		def to_addr
			"0x#{@addr.to_s(16)}"
		end

		def to_value
			"rwo(#{to_addr}, r#{@reg}, 0x#{@v.to_s(16)})"
		end
	end

	class MemrefReg < Memref
		attr_reader :reg
		def initialize(reg)
			@reg = reg
		end
	end

	class MemrefImm < Memref
		attr_reader :value, :size
		def initialize(value, size)
			@value = value
			@size = size
		end

		def to_s
			if @size == 0
				"b[0x%02x]" % [ @value & 0xff ]
			else
				"w[0x%04x]" % [ @value ]
			end
		end

		def to_addr
			"0x%04x" % [@value]
		end
	end

	class MemrefIndirect < Memref
		attr_reader :base, :reg
		def initialize(base, reg)
			@base = base
			@reg = reg
		end

		def to_s
			if @size == 0
				"b[0x%02x + r%d]" % [ @base & 0xff, reg]
			else
				"w[0x%04x + r%d]" % [ @base, reg ]
			end
		end

		def to_addr
			"0x%04x + r%d" % [ @base, reg]
		end
	end

	class Decoder
		attr_reader :instructions

		INS_AND   = 0
		INS_OR    = 1
		INS_NEG   = 2
		INS_SHIFT = 3
		INS_MOV   = 4
		INS_JMP5  = 5
		INS_JMP6  = 6
		INS_JMP7  = 7

		OP_TYPE_REG    = 0
		OP_TYPE_IMM    = 1
		OP_TYPE_MEMREF = 2
		OP_TYPE_OBF    = 3

		MEMREF_REG      = 0
		MEMREF_IMM      = 1
		MEMREF_INDIRECT = 2

		C_TEMPLATE_DATA = <<-EOF
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

#define handle_error(msg) \\
	do { perror(msg); exit(EXIT_FAILURE); } while (0)

#define rb(addr) ( m[(addr)] )
#define rw(addr) ( m[(addr)] | m[(addr) + 1] << 8 )
#define sb(addr,value)  m[(addr)] = (value) & 0xff
#define sw(addr,value) do {\\
	uint16_t __tmp__ = (value); \\
	m[(addr)] = __tmp__ & 0xff;\\
	m[(addr) + 1] = ( __tmp__ >> 8 ) & 0xff;\\
} while(0)

#define rwo(addr,reg,v) ( rw((addr) + (reg)) ^ calc_obf((addr), (reg), (v)) )
#define swo(addr,reg,v,value) sw((addr) + (reg), calc_obf((addr), (reg), (v)) ^ (value))

#define mov(addr,value)            sw((addr), (value))
#define movo(addr,reg,v,value)  swo((addr), (reg), (v), (value))

#define negw(cond,uf,addr)            sw((addr), neg((cond), (uf), rw((addr))))
#define orw(cond,uf,addr,value)       sw((addr), or((cond), (uf), rw((addr)), (value)))
#define andw(cond,uf,addr,value)      sw((addr), and((cond), (uf), rw((addr)), (value)))
#define shiftw(lr,cond,uf,addr,value) sw((addr), shift((lr), (cond), (uf), rw((addr)), (value)))

#define nego(cond,uf,addr,reg,v)            swo( (addr), (reg), (v), neg( (cond), (uf), rwo( (addr), (reg), (v) ) ) )
#define oro(cond,uf,addr,reg,v,value)       swo( (addr), (reg), (v), or( (cond), (uf), rwo( (addr), (reg), (v) ), (value) ) )
#define ando(cond,uf,addr,reg,v,value)      swo( (addr), (reg), (v), and( (cond), (uf), rwo( (addr), (reg), (v) ), (value) ) )
#define shifto(lr,cond,uf,addr,reg,v,value) swo( (addr), (reg), (v), shift( (lr), (cond), (uf), rwo( (addr), (reg), (v) ), (value) ) )

#define ROL(x,b) ( ((x) << (b)) | ((x) >> (16 - (b))) )
#define ROR(x,b) ( ((x) >> (b)) | ((x) << (16 - (b))) )
#define MSB(v)   ( ( (v) >> 15 ) & 1 )

#define LEFT 0
#define RIGHT 1

#define COND0 0
#define COND1 1

#define NO_UF 0
#define DO_UF 1

#define MEM_SIZE 0x10000

uint8_t *m = NULL;
uint8_t c0, c1, z0, z1, s0, s1;

static inline void update_flags(uint8_t cond, uint16_t val) {
	if (cond == 0) {
		z0 = (val == 0);
		s0 = MSB(val);
	} else {
		z1 = (val == 0);
		s1 = MSB(val);
	}
}

static inline uint16_t calc_obf(uint16_t addr, uint16_t reg, uint16_t v) {
	uint16_t r0 = addr, r1 = reg, r2 = v, r5, r6 = 0, r7, r8;
	int i;

	r5 = ( ( ( (r2 << 6) + r2) << 4 ) + r2 ) ^ 0x464d;

	r2 = r0 ^ 0x6c38;

	for (i = 0; i < r1 + 2; i ++) {
		r7 = r6;
		r5 = ROL(r5, 1);
		r2 = ROR(r2, 2);
		r2 += r5;
		r5 += 2;
		r6 = r2 ^ r5;
		r8 = ( (r2 ^ r5) >> 8 ) & 0xff;
		r6 = (r6 & 0xff) ^ r8;
	}

	r6 = (r6 << 8) | r7;

	return r6;
}

static inline uint16_t shift(uint8_t lr, uint8_t cond, uint8_t uf, uint16_t val, uint8_t shift) {
	uint8_t last_shifted;

	if (uf == 1) {
		if (lr == LEFT)
			last_shifted = (val >> (16 - shift)) & 1;
		else
			last_shifted = (val >> (shift - 1)) & 1;

		if (cond == COND0)
			c0 = last_shifted;
		else
			c1 = last_shifted;
	}

	if (lr == LEFT)
		val <<= shift;
	else
		val >>= shift;

	if (uf == 1)
		update_flags(cond, val);

	return val;
}

static inline uint16_t and(uint8_t cond, uint8_t uf, uint16_t v1, uint16_t v2) {
	v1 &= v2;
	if (uf == 1)
		update_flags(cond, v1);
	return v1;
}

static inline uint16_t or(uint8_t cond, uint8_t uf, uint16_t v1, uint16_t v2) {
	v1 |= v2;
	if (uf == 1)
		update_flags(cond, v1);
	return v1;
}

static inline uint16_t neg(uint8_t cond, uint8_t uf, uint16_t v1) {
	v1 = ~v1;
	if (uf == 1)
		update_flags(cond, v1);
	return v1;
}

int f(void) {
	uint8_t ret = 0;
	uint16_t r0, r1, r2,  r3,  r4,  r5,  r6,  r7;
	uint16_t r8, r9, r10, r11, r12, r13, r14, r15;

	c0 = 0; c1 = 0; z0 = 0; z1 = 0;

<% clines.each do |l| %>
<%= l %>
<% end %>

	return ret;
}

void do_init(void) {
	/* TODO : code me ! */
}

int main(int argc, char **argv) {
	uint32_t k1, k2;

	m = calloc(MEM_SIZE, 1);

	do_init();

	for (k1 = 0; k1 < 65536; k1++) {
		for (k2 = 0; k2 < 65536; k2++) {
			sw(0xa000, k1);
			sw(0xa002, k2);
			if (f()) {
				printf("%x %x\\n", k1, k2);
			}
		}
	}
	exit(EXIT_SUCCESS);
}
EOF

		C_TEMPLATE = ERB.new(C_TEMPLATE_DATA, nil, ">")

		def initialize(data)
			@bitstream = data.unpack('B*').first.split(//)
			@instructions = []
			@pc = 0
		end

		def decode
			while not @bitstream.empty?
				di = decode_instruction
				@instructions << di
			end
		end

		def decode_instruction
			ins_pc    = @pc
			cond      = read_bits(1) # cond = 0 : 1
			cond_bits = read_bits(8) # cond_bits = cond_bits(0) | cond_bits(1)
			opcode    = read_bits(3) # opcode de l'instruction
			uf        = read_bits(1) # mise à jour des flags
			ins = Instruction.factory(opcode, ins_pc, cond, cond_bits, uf)
			case ins
			when InsAnd, InsOr, InsMov
				ins << decode_operand
				ins << decode_operand
			when InsNeg
				ins << decode_operand
			when InsShift
				lr = read_bits(1)
				shift = read_byte
				ins << decode_operand
				ins << shift
				ins << lr
			when InsJmp
				v1 = read_bits(6)
				ins << v1
				ins << read_bits(3)
				ins << decode_operand if (v1 == 0)
				ins << @pc
			end
			return ins
		end

		def decode_operand
			size = read_bits(1)
			type = read_bits(2)

			args = []

			case type
			when OP_TYPE_REG
				reg = read_bits(4) # reg
				op = OpReg.new(reg)
			when OP_TYPE_IMM
				value = read_bits( (size == 0) ? 8 : 16 ) # value
				op = OpImm.new(value, size)
			when OP_TYPE_MEMREF
				op = decode_mem_ref(size)
			when OP_TYPE_OBF
				addr = read_bits(16) # addr
				reg = read_bits(4)  # reg
				v = read_bits(6)  # v
				op = OpObf.new(addr, reg, v, size)
			else
				raise "invalid operand type: #{type}"
			end

			return op
		end

		def decode_mem_ref(size)
			memref_type = read_bits(2)
			mr = nil

			case memref_type
			when MEMREF_REG
				reg = read_reg
				mr = MemrefReg.new(reg)
			when MEMREF_IMM
				value = read_word
				mr = MemrefImm.new(value, size)
			when MEMREF_INDIRECT
				value = read_word
				reg = read_reg
				mr = MemrefIndirect.new(value, reg)
			end

			return mr
		end

		def read_word ; read_bits(16) ; end
		def read_byte ; read_bits(8) ; end
		def read_reg ; read_bits(4); end

		def read_bits(n)
			@pc += n
			@bitstream.shift(n).join('').to_i(2)
		end

		def compile
			clines = []
			locations = @instructions.select {|di| di.instance_of? InsJmp }.map {|di| di.next_pc }.sort.uniq
			@instructions.each do |di|
				pc_a = di.pc_to_a
				if locations.include? pc_a
					clines <<  ( "\nloc_%04d_%d:\n" % (pc_a) )
				end
				clines << "\t// #{di}\n"
				clines << "\t" << di.to_c << "\n"
			end

			return C_TEMPLATE.result(binding)
		end

	end

end

options = {:disas => false, :compile => false, :input => nil, :output => nil}

optparse = OptionParser.new do|opts|
  opts.on( '-h', '--help', 'show help') do
    puts opts
    exit
  end
  opts.on( '-i', '--input FILE', 'Input file') do |f|
    options[:input] = f
  end
  opts.on( '-o', '--output FILE', 'Output file') do |f|
    options[:output] = f
  end
  opts.on( '-d', '--disas', 'Disassemble specified input file') do
    options[:disas] = true
  end
  opts.on( '-c', '--compile', 'Disassemble then compile specified input file') do
    options[:compile] = true
  end
end

optparse.parse!

unless options[:input]
  puts "Missing input file"
  puts optparse
  exit
end

unless options[:output]
  puts "Missing output file"
  puts optparse
  exit
end

if not options[:disas] and not options[:compile] then
  puts "Missing operational mode"
  puts optparse
  exit
end

File.open(options[:output], "w") do |fo|
  data = File.open(options[:input], "rb").read
  decoder = VM::Decoder.new(data)
  decoder.decode
  if options[:disas] then
    decoder.instructions.each do |di|
      fo.puts(di.to_s)
    end
  end

  if options[:compile] then
    fo.write(decoder.compile)
  end
end
