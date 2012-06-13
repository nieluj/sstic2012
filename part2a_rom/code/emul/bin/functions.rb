# ce fichier doit être mis à jour pour prendre les modifications apportées à server.h / server.c
# au niveau du nombre de paramètres des fonctions

sub_1da = CY16::Function.new(0x41da, "sub_41da", [:r0, :r1], [:r0],
                             [0x4054, 0x4056, 0x4058, 0x405a, 0x405c, 0x405e, 0x4060, 0x4062, 0x4064, 0x4066, 0x406e, 0x4120, 0x4122, 0x4124],
                             [0x4054, 0x4056, 0x4058, 0x405a, 0x405c, 0x405e, 0x4060, 0x4062, 0x4064, 0x4066, 0x4068, 0x406a, 0x406e, 0x411a, 0x411c, 0x411e])

sub_1a6 = CY16::Function.new(0x41a6, "sub_41a6", [:r0, :r1, :r2], [:r0])
sub_1a6 << sub_1da

sub_166 = CY16::Function.new(0x4166, "sub_4166", [:r0, :r1, :r2], [:r0], [0x4072], [0x4072])
sub_166 << sub_1a6

sub_162 = CY16::Function.new(0x4162, "sub_4162", [:r0, :r1, :r2], [:r0])
sub_162 << sub_166

sub_146 = CY16::Function.new(0x4146, "sub_4146", [:r0, :r1], [:r0])
sub_156 = CY16::Function.new(0x4156, "sub_4156", [:r0, :r1], [:r0])

sub_268 = CY16::Function.new(0x4268, "read_nbits", [:r0], [:r0],
                             [0x411c, 0x411e],
                             [0x411c, 0x411e])
sub_268 << sub_162
sub_268 << sub_146
sub_268 << sub_156

sub_346 = CY16::Function.new(0x4346, "set_dest_operand", [], [],
                             [ 0x4126, 0x4128, 0x412a, 0x412c, 0x412e, 0x4130],
                             [ 0x4134, 0x4136, 0x4138, 0x413a, 0x413c, 0x413e])


sub_84c = CY16::Function.new(0x484c, "sub_484c", [:r0, :r1, :r2, :r3, :r4, :r6], [:r0])
sub_84c << sub_166

sub_848 = CY16::Function.new(0x4848, "sub_4848", [:r0, :r1, :r2, :r3, :r4, :r6], [:r0])
sub_848 << sub_84c

sub_35e = CY16::Function.new(0x435e, "save_dest", [:r6], [],
                             [0x40fe, 0x4100, 0x4102, 0x4104, 0x4106, 0x4108, 0x4126, 0x4136, 0x4138, 0x413a, 0x413c],
                             [0x40fe, 0x4100, 0x4102, 0x4104, 0x4106, 0x4108])
sub_35e << sub_166
sub_35e << sub_84c

sub_3c4 = CY16::Function.new(0x43c4, "decode_operands", [:r2, :r4, :r6], [:r0],
                              [0x40fe, 0x4100, 0x4102, 0x4104, 0x4106, 0x4108, 0x412a, 0x412c, 0x412e],
                              [0x4126, 0x4128, 0x412a, 0x412c, 0x412e, 0x4130, 0x4132])
sub_3c4 << sub_268
sub_3c4 << sub_162
sub_3c4 << sub_848

sub_814 = CY16::Function.new(0x4814, "sub_4814", [:r6, :r14], [],
                             [0x4144, 0xc000],
                             [0x4144])

sub_4da = CY16::Function.new(0x44da, "do_instruction", [], [],
                             [0x411a, 0x411c, 0x411e, 0x4126, 0x4128, 0x412a, 0x412c, 0x412e, 0x4130, 0x4132, 0x4134, 0x4140, 0x4142, 0x4144],
                             [0x411a, 0x411c, 0x411e, 0x4120, 0x4122, 0x4124, 0x4126, 0x412a, 0x4140, 0x4142, 0x4144])
sub_4da << sub_166
sub_4da << sub_268
sub_4da << sub_346
sub_4da << sub_3c4
sub_4da << sub_35e
sub_4da << sub_814
sub_4da << sub_848
sub_4da << sub_84c

sub_0f6 = CY16::Function.new(0x40f6, "sub_40f6", [], [])
sub_0f6 << sub_4da

sub_0e8 = CY16::Function.new(0x40e8, "sub_40e8", [], [],
                             [0x4120],
                             []
                            )

$functions = [ sub_0e8, sub_0f6, sub_146, sub_156, sub_162, sub_166, sub_1a6, sub_1da,
  sub_268, sub_346, sub_3c4, sub_35e, sub_4da, sub_814, sub_848, sub_84c ]
