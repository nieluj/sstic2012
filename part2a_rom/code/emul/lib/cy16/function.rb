module CY16
  class Function
    attr_reader :addr, :fname, :read, :write, :reg_in, :reg_out

    def initialize(addr, fname, reg_in = [:r0], reg_out = [:r0], read = [], write = [])
      @addr = addr
      @fname = fname
      @sub = []
      @reg_in = reg_in
      @reg_out = reg_out
      @read = read
      @write = write
    end

    def <<(subf)
      @sub << subf
      subf.read.each do |a|
        @read << a unless @read.include?(a)
      end

      subf.write.each do |a|
        @write << a unless @write.include?(a)
      end
    end

  end
end
