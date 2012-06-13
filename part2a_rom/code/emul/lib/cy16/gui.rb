#!/usr/bin/env ruby

require 'cy16/metaemul'
require 'Qt4'

module CY16

class FlagsWidget < Qt::Widget
  def initialize(app, font)
    super()
    @font = font
    @layout = Qt::HBoxLayout.new
    @layout.addWidget Qt::Label.new("z")
    @zwd = Qt::LineEdit.new
    @layout.addWidget @zwd
    @layout.addWidget Qt::Label.new("s")
    @swd = Qt::LineEdit.new
    @layout.addWidget @swd
    @layout.addWidget Qt::Label.new("c")
    @cwd = Qt::LineEdit.new
    @layout.addWidget @cwd
    @layout.addWidget Qt::Label.new("o")
    @owd = Qt::LineEdit.new
    @layout.addWidget @owd

    @widgets = [ @zwd, @swd, @cwd, @owd ]

    @defstyle = "QLineEdit {background-color: #FFFFFF; color: #000000;}"
    @changedstyle = "QLineEdit {background-color: #FFFFFF; color: #FF0000;}"

    setLayout(@layout)
  end

  def update_flags(st, previous_st = nil)
    @zwd.setText("#{st.z}")
    @zwd.setStyleSheet(@defstyle)
    if previous_st and previous_st.z != st.z then
      @zwd.setStyleSheet(@changedstyle)
    end
    @swd.setText("#{st.s}")
    @swd.setStyleSheet(@defstyle)
    if previous_st and previous_st.s != st.s then
      @swd.setStyleSheet(@changedstyle)
    end
    @cwd.setText("#{st.c}")
    @cwd.setStyleSheet(@defstyle)
    if previous_st and previous_st.c != st.c then
      @cwd.setStyleSheet(@changedstyle)
    end
    @owd.setText("#{st.o}")
    @owd.setStyleSheet(@defstyle)
    if previous_st and previous_st.o != st.o then
      @owd.setStyleSheet(@changedstyle)
    end
    @widgets.each do |w|
      w.setFont(font)
    end
  end
end

class RegistersWidget < Qt::Widget
  def initialize(app, font)
    super()
    @font = font
    @grid = Qt::GridLayout.new
    @widgets = []
    row, col = 0, 0
    0.upto(15).each do |i|
      label = Qt::Label.new("r#{i}")
      @grid.addWidget label, row, col
      col += 1
      le = Qt::LineEdit.new
      @widgets << le
      @grid.addWidget le, row, col
      col += 1
      if col == 8 then
        row += 1
        col = 0
      end
    end
    @defstyle = "QLineEdit {background-color: #FFFFFF; color: #000000;}"
    @changedstyle = "QLineEdit {background-color: #FFFFFF; color: #FF0000;}"

    setLayout(@grid)
  end

  def update_reg(st, previous_st = nil)
    st.gpr.each_with_index do |v, i|
      reg_s = "%04x" % v
      @widgets[i].setText(reg_s)
      @widgets[i].setStyleSheet(@defstyle)
      if previous_st and previous_st.gpr[i] != v
        @widgets[i].setStyleSheet(@changedstyle)
      end
      @widgets[i].setFont(@font)
    end
  end
end

class EmulWidget < Qt::Widget
  slots 'selectionChanged()'

  def initialize(app)
    super()
    @stcount = 0
    @states = []
    @states_from_item = {}

    monofont = Qt::Font.new "Ubuntu Mono", 11
    @grid = Qt::GridLayout.new

    @list = Qt::ListWidget.new
    @list.setFont(monofont)
    connect(@list, SIGNAL('itemSelectionChanged()'), self, SLOT('selectionChanged()'))

    quit = Qt::PushButton.new('Quit')
    connect(quit, SIGNAL('clicked()'), app, SLOT('quit()'))

    flags_label = Qt::Label.new("Flags")
    @flags = FlagsWidget.new(app, monofont)
    reg_label = Qt::Label.new("Registers")
    #@registers = Qt::TextEdit.new("Registers")
    @registers = RegistersWidget.new(app, monofont)
    memdump_label = Qt::Label.new("Memory dump")
    @memdump = Qt::TextEdit.new("Memdump")
    @memdump.setFont(monofont)
    @flags.setFont(monofont)
    @registers.setFont(monofont)

    # int row, int column, int rowSpan = 1, int columnSpan = 1,
    @grid.addWidget @list,         0, 0, 6, 1
    @grid.addWidget quit,          6, 0
    @grid.addWidget flags_label,   0, 1
    @grid.addWidget @flags,        1, 1
    @grid.addWidget reg_label,     2, 1
    @grid.addWidget @registers,    3, 1
    @grid.addWidget memdump_label, 4, 1
    @grid.addWidget @memdump,      5, 1

    @grid.setColumnStretch(0, 2)
    @grid.setColumnStretch(1, 1)
    @grid.setRowStretch(5, 1)
    setLayout(@grid)
  end

  def selectionChanged()
    it = @list.currentItem()
    stidx = @states_from_item[it]
    addr, st = @states[stidx]
    #puts st.di
    #puts st.gpr.map {|x| "%04x" % x }.join(' ')
    update(stidx, addr, st)
  end

  def update(stidx, addr, st)
    previous_st = (stidx > 0) ? @states[stidx - 1][1] : nil

    @flags.update_flags(st, previous_st)
    @registers.update_reg(st, previous_st)

    @memdump.setText(st.memdump)
    @grid.activate
  end

  def add_saved_state(addr, st)
    item = Qt::ListWidgetItem.new("#{st.di}", @list)
    #puts "adding state #{st} for addr #{addr}"
    @states << [ addr, st ]
    @states_from_item[item] = @stcount
    @stcount += 1
  end
end

end
