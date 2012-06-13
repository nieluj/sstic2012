require 'erb'
require 'set'

class UnitTest
  attr_reader :func, :mem_read, :mem_write, :retval, :number

  TEMPLATE_DATA = <<-EOF
/* data = <%= @data.bin_to_hex.gsub(/\s/, '') %>, offset = <%= "0x%04x" % @offset %> */
void test_<%= @func.fname %>_<%= @number %>(void) {
    uint16_t ret;
    printf("[?] test <%= @number %> for function <%= @func.fname %>\\n");
    printf("data = <%= @data.bin_to_hex.gsub(/\s/, '') %>, offset = <%= "0x%04x" % @offset %>\\n");

    clear_mem();
    jmp_set = 0;
<% @mem_read.each do |addr, value| %>
    sw(0x<%= addr.to_s(16) %>, 0x<%= value.to_s(16) %>);
<% end %>

<% if @retval %>
    ret = <%= @func.fname %>(<%= @func_values.map {|x| "0x" + x.to_s(16) }.join(', ') %>);
    printf("ret: 0x%04x == 0x<%= @retval.to_s(16) %>\\n", ret);
    assert(ret == 0x<%= @retval.to_s(16) %>);
<% else %>
    <%= @func.fname %>(<%= @func_values.map {|x| "0x" + x.to_s(16) }.join(', ') %>);
<% end %>

<% @mem_write.each do |addr, value| %>
    printf("w[0x<%= addr.to_s(16) %>]: 0x%04x == 0x<%= value.to_s(16) %> ?\\n", rw(0x<%= addr.to_s(16) %>));
    assert(rw(0x<%= addr.to_s(16) %>) == 0x<%= value.to_s(16) %>);
<% end %>

    printf("[+] test <%= @number %> passed for function <%= @func.fname %> !\\n");
}
EOF

  TEMPLATE= ERB.new(TEMPLATE_DATA, nil, ">")

  def initialize(call_state, ret_state, func, data, offset, number)
    raise unless call_state and ret_state
    @func = func
    @data = data
    @offset = offset
    @func_values = func.reg_in.map { |r| call_state.rr(r) }
    @mem_read = {}
    @mem_write = {}
    @retval = nil
    @number = number

    #@func.read.each do |addr|
    #  @mem_read[addr] = call_state.rw(addr)
    #end

    call_state.mem.each do |addr, len, data|
      data.pack('C*').unpack('v*').each do |w|
        if w != 0 then
          @mem_read[addr] = w
        end
        addr += 2
      end
    end

    @func.write.each do |addr|
      @mem_write[addr] = ret_state.rw(addr)
    end

    unless @func.reg_out.empty?
      @retval = ret_state.rr(@func.reg_out.first)
    end
  end

  def ==(other)
    return false unless @func == o.func
    return false unless @mem_read == o.mem_read
    return false unless @mem_write == o.mem_write
    return false unless @retval == o.retval
    return true
  end

  def hash
    ret = @func.addr

    @mem_read.each do |addr, value|
      ret ^= (addr ^ value)
    end

    @mem_write.each do |addr, value|
      ret ^= (addr ^ value)
    end

    ret ^= @retval if @retval
    return ret
  end

  def generate
    return TEMPLATE.result(binding)
  end

end

class TestGenerator
  attr_accessor :data, :offset

  TEMPLATE_DATA = <<-EOF
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>

#include "server.h"

extern uint8_t *m;
extern int jmp_set;

<% @tests.each do |t| %>

<%= t.generate %>

<% end %>

void do_func_test(void) {
    uint16_t ret;

    /* initial values */
    sw(0x4054, 0xfff1);
    sw(0x4056, 0xfff2);
    sw(0x4058, 0xfff3);
    sw(0x405a, 0xfff4);
    sw(0x405c, 0xfff5);
    sw(0x405e, 0xffff);
    sw(0x4060, 0xffff);
    sw(0x4062, 0xffff);
    sw(0x4064, 0xffff);
    sw(0x4066, 0xffff);
    sw(0x4068, 0x4000);
    sw(0x406a, 0x4054);

<% @tests.each do |t| %>
    test_<%= t.func.fname %>_<%= t.number %>();
<% end %>
}

void do_test(void) {
    uint16_t t = 0xffff;
    printf("[?] doing basic tests\\n");
    sw(0x4000, 0xdead);
    assert(rw(0x4000) == 0xdead);

    sw(0x4002, 1);
    assert(rw(0x4002) == 1);

    addw(0x4002, 5);
    assert(rw(0x4002) == 6);

    incw(0x4002);
    assert(rw(0x4002) == 7);

    sw(0x4004, 0xffff);
    incw(0x4004);
    t++;
    printf("v = 0x%04x, 0x%04x\\n", rw(0x4004), t);
    assert(rw(0x4004) == 0);

    printf("[+] basic tests passed\\n");
}

int main(int argc, char **argv) {
    do_mem_init();
    do_server_init();

    do_test();
    do_func_test();
    exit(EXIT_SUCCESS);
}

EOF

  TEMPLATE= ERB.new(TEMPLATE_DATA, nil, ">")

  def initialize(path)
    @output = File.expand_path(path)

    @data = nil
    @offset = nil
    @tests = Set.new
    @count = 0
  end

  def <<(a)
    func, call_state, ret_state = *a
    @tests << UnitTest.new(call_state, ret_state, func, @data, @offset, @count)
    @count += 1
  end

  def generate
    File.open(@output, "w") do |f|
      f.write TEMPLATE.result(binding)
    end
  end

end
