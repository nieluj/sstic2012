[0000:0][c=0][uf=0] mov r13, r7
[0003:3][c=0][uf=0] and r9, 0x0000
[0008:2][c=0][uf=0] mov obf(0xdb2a, r9, 0x3b), w[0xa000]
[0016:1][c=0][uf=0] mov obf(0xd73c, r9, 0x28), r2
[0022:2][c=0][uf=0] or obf(0xd73c, r9, 0x28), r0
[0028:3][c=0][uf=0] mov r0, w[0xa002]
[0033:4][c=0][uf=0] mov obf(0xd9a6, r9, 0x18), 0x6e63
[0041:1][c=0][uf=0] shift right obf(0xd9a6, r9, 0x18), 1
[0047:4][c=0][uf=0] mov r12, obf(0xdb2a, r9, 0x3b)
[0053:5][c=0][uf=0] and r12, 0x00ff
[0058:4][c=0][uf=0] mov obf(0xf9c4, r9, 0x29), r12
[0064:5][c=0][uf=0] mov obf(0xdf0c, r9, 0x7), r0
[0070:6][c=0][uf=0] and obf(0xdf0c, r9, 0x7), 0x00ff
[0078:3][c=0][uf=0] mov obf(0xef0c, r9, 0x13), r4
[0084:4][c=0][uf=0] or obf(0xef0c, r9, 0x13), r7
[0090:5][c=0][uf=0] mov obf(0xc910, r9, 0xc), obf(0xf9c4, r9, 0x29)
[0099:4][c=0][uf=0] and obf(0xc910, r9, 0xc), obf(0xdf0c, r9, 0x7)
[0108:3][c=0][uf=0] neg obf(0xc910, r9, 0xc)
[0113:5][c=0][uf=0] mov obf(0xfdee, r9, 0x35), obf(0xf9c4, r9, 0x29)
[0122:4][c=0][uf=0] or obf(0xfdee, r9, 0x35), obf(0xdf0c, r9, 0x7)
[0131:3][c=0][uf=0] and obf(0xc910, r9, 0xc), obf(0xfdee, r9, 0x35)
[0140:2][c=0][uf=0] mov r13, obf(0xc910, r9, 0xc)
[0146:3][c=0][uf=0] mov obf(0xfb78, r9, 0x2e), obf(0xdb2a, r9, 0x3b)
[0155:2][c=0][uf=0] shift right obf(0xfb78, r9, 0x2e), 8
[0161:5][c=0][uf=0] mov obf(0xf9c4, r9, 0x29), obf(0xfb78, r9, 0x2e)
[0170:4][c=0][uf=0] mov obf(0xfb78, r9, 0x2e), r2
[0176:5][c=0][uf=0] mov obf(0xe462, r9, 0x23), r0
[0182:6][c=0][uf=0] shift right obf(0xe462, r9, 0x23), 8
[0189:1][c=0][uf=0] mov obf(0xdf0c, r9, 0x7), obf(0xe462, r9, 0x23)
[0198:0][c=0][uf=0] mov obf(0xdfc8, r9, 0x35), obf(0xf9c4, r9, 0x29)
[0206:7][c=0][uf=0] neg obf(0xdfc8, r9, 0x35)
[0212:1][c=0][uf=0] and obf(0xdfc8, r9, 0x35), obf(0xdf0c, r9, 0x7)
[0221:0][c=0][uf=0] mov obf(0xea26, r9, 0x31), obf(0xf9c4, r9, 0x29)
[0229:7][c=0][uf=0] neg obf(0xea26, r9, 0x31)
[0235:1][c=0][uf=0] or obf(0xea26, r9, 0x31), obf(0xdf0c, r9, 0x7)
[0244:0][c=0][uf=0] neg obf(0xea26, r9, 0x31)
[0249:2][c=0][uf=0] or obf(0xdfc8, r9, 0x35), obf(0xea26, r9, 0x31)
[0258:1][c=0][uf=0] mov r7, obf(0xdfc8, r9, 0x35)
[0264:2][c=0][uf=0] mov obf(0xf390, r9, 0x6), r8
[0270:3][c=0][uf=0] mov obf(0xf740, r9, 0x31), r7
[0276:4][c=0][uf=0] shift left obf(0xf740, r9, 0x31), 8
[0282:7][c=0][uf=0] mov obf(0xdb2a, r9, 0x3b), obf(0xf740, r9, 0x31)
[0291:6][c=0][uf=0] mov obf(0xf740, r9, 0x31), r11
[0297:7][c=0][uf=0] mov obf(0xd944, r9, 0xd), 0x4cf0
[0305:4][c=0][uf=0] mov obf(0xf49c, r9, 0x2), r7
[0311:5][c=0][uf=0] mov obf(0xe216, r9, 0xc), r13
[0317:6][c=0][uf=0] mov r12, obf(0xf49c, r9, 0x2)
[0323:7][c=0][uf=0] mov obf(0xe5a0, r9, 0x2b), obf(0xe216, r9, 0xc)
[0332:6][c=0][uf=0] neg obf(0xe5a0, r9, 0x2b)
[0338:0][c=0][uf=0] and r12, obf(0xe5a0, r9, 0x2b)
[0344:1][c=0][uf=0] mov obf(0xe5a0, r9, 0x2b), r12
[0350:2][c=0][uf=0] mov obf(0xd666, r9, 0x1d), obf(0xf49c, r9, 0x2)
[0359:1][c=0][uf=0] mov obf(0xc9c0, r9, 0xc), obf(0xe216, r9, 0xc)
[0368:0][c=0][uf=0] neg obf(0xc9c0, r9, 0xc)
[0373:2][c=0][uf=0] or obf(0xd666, r9, 0x1d), obf(0xc9c0, r9, 0xc)
[0382:1][c=0][uf=0] neg obf(0xd666, r9, 0x1d)
[0387:3][c=0][uf=0] or obf(0xe5a0, r9, 0x2b), obf(0xd666, r9, 0x1d)
[0396:2][c=0][uf=0] mov obf(0xea26, r9, 0x31), obf(0xe5a0, r9, 0x2b)
[0405:1][c=0][uf=0] and obf(0xf49c, r9, 0x2), obf(0xe216, r9, 0xc)
[0414:0][c=0][uf=0] mov obf(0xe216, r9, 0xc), obf(0xf49c, r9, 0x2)
[0422:7][c=0][uf=0] mov obf(0xf49c, r9, 0x2), obf(0xea26, r9, 0x31)
[0431:6][c=0][uf=1] shift left obf(0xe216, r9, 0xc), 1
[0438:1][c=0][uf=0] or c obf(0xd944, r9, 0xd), 0xa1a6
[0445:6][c=0][uf=1] and obf(0xe216, r9, 0xc), obf(0xe216, r9, 0xc)
[0454:5][c=0][uf=0] jmp nz 0317:6
[0459:6][c=0][uf=0] neg obf(0xd944, r9, 0xd)
[0465:0][c=0][uf=1] shift left obf(0xd944, r9, 0xd), 1
[0471:3][c=0][uf=0] mov r13, obf(0xf49c, r9, 0x2)
[0477:4][c=0][uf=0] mov obf(0xea26, r9, 0x31), 0x6d6d
[0485:1][c=0][uf=0] mov obf(0xc82a, r9, 0x3d), r13
[0491:2][c=0][uf=0] mov obf(0xf97a, r9, 0xf), obf(0xdb2a, r9, 0x3b)
[0500:1][c=0][uf=0] mov obf(0xe38e, r9, 0x27), obf(0xc82a, r9, 0x3d)
[0509:0][c=0][uf=0] mov obf(0xc07c, r9, 0x11), obf(0xf97a, r9, 0xf)
[0517:7][c=0][uf=0] neg obf(0xc07c, r9, 0x11)
[0523:1][c=0][uf=0] and obf(0xe38e, r9, 0x27), obf(0xc07c, r9, 0x11)
[0532:0][c=0][uf=0] mov obf(0xc07c, r9, 0x11), obf(0xe38e, r9, 0x27)
[0540:7][c=0][uf=0] mov obf(0xdbc6, r9, 0x24), obf(0xc82a, r9, 0x3d)
[0549:6][c=0][uf=0] mov obf(0xc76e, r9, 0x3), obf(0xf97a, r9, 0xf)
[0558:5][c=0][uf=0] neg obf(0xc76e, r9, 0x3)
[0563:7][c=0][uf=0] or obf(0xdbc6, r9, 0x24), obf(0xc76e, r9, 0x3)
[0572:6][c=0][uf=0] neg obf(0xdbc6, r9, 0x24)
[0578:0][c=0][uf=0] or obf(0xc07c, r9, 0x11), obf(0xdbc6, r9, 0x24)
[0586:7][c=0][uf=0] mov obf(0xcb82, r9, 0xe), obf(0xc07c, r9, 0x11)
[0595:6][c=0][uf=0] and obf(0xc82a, r9, 0x3d), obf(0xf97a, r9, 0xf)
[0604:5][c=0][uf=0] mov obf(0xf97a, r9, 0xf), obf(0xc82a, r9, 0x3d)
[0613:4][c=0][uf=0] mov obf(0xc82a, r9, 0x3d), obf(0xcb82, r9, 0xe)
[0622:3][c=1][uf=1] shift left obf(0xf97a, r9, 0xf), 1
[0628:6][c=1][uf=0] or c obf(0xea26, r9, 0x31), 0xac93
[0636:3][c=1][uf=1] and obf(0xf97a, r9, 0xf), obf(0xf97a, r9, 0xf)
[0645:2][c=1][uf=0] jmp nz 0500:1
[0650:3][c=0][uf=0] neg obf(0xea26, r9, 0x31)
[0655:5][c=1][uf=1] shift left obf(0xea26, r9, 0x31), 1
[0662:0][c=0][uf=0] mov obf(0xdb2a, r9, 0x3b), obf(0xc82a, r9, 0x3d)
[0670:7][c=0][uf=0] mov obf(0xea26, r9, 0x31), 0x0000
[0678:4][c=0][uf=0] mov obf(0xf9ca, r9, 0x3b), r7
[0684:5][c=0][uf=0] and obf(0xf9ca, r9, 0x3b), r0
[0690:6][c=0][uf=0] mov r0, 0x0004
[0695:5][c=0][uf=0] mov obf(0xd3d4, r9, 0x26), 0x7703
[0703:2][c=0][uf=0] shift left obf(0xd3d4, r9, 0x26), 1
[0709:5][c=0][uf=0] mov obf(0xf7f8, r9, 0x9), obf(0xa00c, r0, 0x33)
[0718:4][c=0][uf=0] mov obf(0xc2d2, r9, 0x10), 0x416e
[0726:1][c=0][uf=0] mov r12, obf(0xf7f8, r9, 0x9)
[0732:2][c=0][uf=0] or r12, obf(0xdb2a, r9, 0x3b)
[0738:3][c=0][uf=0] neg r12
[0740:7][c=0][uf=0] neg r12
[0743:3][c=0][uf=0] mov obf(0xd5aa, r9, 0x20), obf(0xf7f8, r9, 0x9)
[0752:2][c=0][uf=0] and obf(0xd5aa, r9, 0x20), obf(0xdb2a, r9, 0x3b)
[0761:1][c=0][uf=0] neg obf(0xd5aa, r9, 0x20)
[0766:3][c=0][uf=0] and r12, obf(0xd5aa, r9, 0x20)
[0772:4][c=0][uf=0] mov obf(0xf7f8, r9, 0x9), r12
[0778:5][c=0][uf=0] mov r12, r8
[0782:0][c=0][uf=0] and r12, r0
[0785:3][c=0][uf=0] mov w[0xa00c + r0], obf(0xf7f8, r9, 0x9)
[0793:6][c=0][uf=0] mov obf(0xd062, r9, 0x36), r7
[0799:7][c=0][uf=0] mov obf(0xec5a, r9, 0x2d), 0x2619
[0807:4][c=0][uf=0] mov obf(0xc430, r9, 0x3c), 0x0001
[0815:1][c=0][uf=0] mov obf(0xf850, r9, 0xd), obf(0xea26, r9, 0x31)
[0824:0][c=0][uf=0] mov r12, obf(0xc430, r9, 0x3c)
[0830:1][c=0][uf=0] and r12, obf(0xf850, r9, 0xd)
[0836:2][c=0][uf=0] neg r12
[0838:6][c=0][uf=0] mov obf(0xd920, r9, 0x7), obf(0xc430, r9, 0x3c)
[0847:5][c=0][uf=0] or obf(0xd920, r9, 0x7), obf(0xf850, r9, 0xd)
[0856:4][c=0][uf=0] neg obf(0xd920, r9, 0x7)
[0861:6][c=0][uf=0] neg obf(0xd920, r9, 0x7)
[0867:0][c=0][uf=0] and r12, obf(0xd920, r9, 0x7)
[0873:1][c=0][uf=0] mov obf(0xc99a, r9, 0x9), r12
[0879:2][c=0][uf=0] and obf(0xc430, r9, 0x3c), obf(0xf850, r9, 0xd)
[0888:1][c=0][uf=0] mov obf(0xf850, r9, 0xd), obf(0xc430, r9, 0x3c)
[0897:0][c=0][uf=0] mov obf(0xc430, r9, 0x3c), obf(0xc99a, r9, 0x9)
[0905:7][c=1][uf=1] shift left obf(0xf850, r9, 0xd), 1
[0912:2][c=1][uf=0] or c obf(0xec5a, r9, 0x2d), 0x9994
[0919:7][c=1][uf=1] and obf(0xf850, r9, 0xd), obf(0xf850, r9, 0xd)
[0928:6][c=1][uf=0] jmp nz 0824:0
[0933:7][c=0][uf=0] neg obf(0xec5a, r9, 0x2d)
[0939:1][c=1][uf=1] shift left obf(0xec5a, r9, 0x2d), 1
[0945:4][c=0][uf=0] mov obf(0xea26, r9, 0x31), obf(0xc430, r9, 0x3c)
[0954:3][c=0][uf=0] mov obf(0xec5a, r9, 0x2d), r3
[0960:4][c=0][uf=0] or obf(0xec5a, r9, 0x2d), r5
[0966:5][c=0][uf=0] mov obf(0xcd96, r9, 0x25), 0x7eb2
[0974:2][c=0][uf=0] mov obf(0xe292, r9, 0xa), 0x0002
[0981:7][c=0][uf=0] mov obf(0xd5a4, r9, 0x2e), r0
[0988:0][c=0][uf=0] mov obf(0xd904, r9, 0x11), obf(0xe292, r9, 0xa)
[0996:7][c=0][uf=0] and obf(0xd904, r9, 0x11), obf(0xd5a4, r9, 0x2e)
[1005:6][c=0][uf=0] neg obf(0xd904, r9, 0x11)
[1011:0][c=0][uf=0] mov r12, obf(0xe292, r9, 0xa)
[1017:1][c=0][uf=0] or r12, obf(0xd5a4, r9, 0x2e)
[1023:2][c=0][uf=0] neg r12
[1025:6][c=0][uf=0] neg r12
[1028:2][c=0][uf=0] and obf(0xd904, r9, 0x11), r12
[1034:3][c=0][uf=0] mov obf(0xead6, r9, 0x11), obf(0xd904, r9, 0x11)
[1043:2][c=0][uf=0] and obf(0xe292, r9, 0xa), obf(0xd5a4, r9, 0x2e)
[1052:1][c=0][uf=0] mov obf(0xd5a4, r9, 0x2e), obf(0xe292, r9, 0xa)
[1061:0][c=0][uf=0] mov obf(0xe292, r9, 0xa), obf(0xead6, r9, 0x11)
[1069:7][c=1][uf=1] shift left obf(0xd5a4, r9, 0x2e), 1
[1076:2][c=1][uf=0] or c obf(0xcd96, r9, 0x25), 0x8a22
[1083:7][c=1][uf=1] and obf(0xd5a4, r9, 0x2e), obf(0xd5a4, r9, 0x2e)
[1092:6][c=1][uf=0] jmp nz 0988:0
[1097:7][c=0][uf=0] neg obf(0xcd96, r9, 0x25)
[1103:1][c=1][uf=1] shift left obf(0xcd96, r9, 0x25), 1
[1109:4][c=0][uf=0] mov r0, obf(0xe292, r9, 0xa)
[1115:5][c=0][uf=0] mov obf(0xead6, r9, 0x11), obf(0xea26, r9, 0x31)
[1124:4][c=0][uf=0] mov obf(0xd5a4, r9, 0x2e), 0x0010
[1132:1][c=0][uf=0] neg obf(0xd5a4, r9, 0x2e)
[1137:3][c=0][uf=0] mov obf(0xf106, r9, 0x33), 0x684e
[1145:0][c=0][uf=0] mov obf(0xcec2, r9, 0x3b), 0x0001
[1152:5][c=0][uf=0] mov obf(0xe244, r9, 0x33), obf(0xd5a4, r9, 0x2e)
[1161:4][c=0][uf=0] mov obf(0xe0fe, r9, 0x1f), obf(0xcec2, r9, 0x3b)
[1170:3][c=0][uf=0] mov obf(0xd5ae, r9, 0x33), obf(0xe244, r9, 0x33)
[1179:2][c=0][uf=0] neg obf(0xd5ae, r9, 0x33)
[1184:4][c=0][uf=0] or obf(0xe0fe, r9, 0x1f), obf(0xd5ae, r9, 0x33)
[1193:3][c=0][uf=0] neg obf(0xe0fe, r9, 0x1f)
[1198:5][c=0][uf=0] mov obf(0xec46, r9, 0x28), obf(0xcec2, r9, 0x3b)
[1207:4][c=0][uf=0] mov obf(0xe388, r9, 0x2f), obf(0xe244, r9, 0x33)
[1216:3][c=0][uf=0] neg obf(0xe388, r9, 0x2f)
[1221:5][c=0][uf=0] and obf(0xec46, r9, 0x28), obf(0xe388, r9, 0x2f)
[1230:4][c=0][uf=0] or obf(0xe0fe, r9, 0x1f), obf(0xec46, r9, 0x28)
[1239:3][c=0][uf=0] mov obf(0xf2bc, r9, 0x35), obf(0xe0fe, r9, 0x1f)
[1248:2][c=0][uf=0] and obf(0xcec2, r9, 0x3b), obf(0xe244, r9, 0x33)
[1257:1][c=0][uf=0] mov obf(0xe244, r9, 0x33), obf(0xcec2, r9, 0x3b)
[1266:0][c=0][uf=0] mov obf(0xcec2, r9, 0x3b), obf(0xf2bc, r9, 0x35)
[1274:7][c=1][uf=1] shift left obf(0xe244, r9, 0x33), 1
[1281:2][c=1][uf=0] or c obf(0xf106, r9, 0x33), 0xc433
[1288:7][c=1][uf=1] and obf(0xe244, r9, 0x33), obf(0xe244, r9, 0x33)
[1297:6][c=1][uf=0] jmp nz 1161:4
[1302:7][c=0][uf=0] neg obf(0xf106, r9, 0x33)
[1308:1][c=1][uf=1] shift left obf(0xf106, r9, 0x33), 1
[1314:4][c=0][uf=0] mov obf(0xd5a4, r9, 0x2e), obf(0xcec2, r9, 0x3b)
[1323:3][c=0][uf=0] mov obf(0xe1a6, r9, 0xb), 0x2930
[1331:0][c=0][uf=0] mov obf(0xda82, r9, 0x24), obf(0xead6, r9, 0x11)
[1339:7][c=0][uf=0] mov obf(0xe20e, r9, 0x37), obf(0xd5a4, r9, 0x2e)
[1348:6][c=0][uf=0] mov obf(0xd5f8, r9, 0x25), obf(0xda82, r9, 0x24)
[1357:5][c=0][uf=0] neg obf(0xd5f8, r9, 0x25)
[1362:7][c=0][uf=0] and obf(0xd5f8, r9, 0x25), obf(0xe20e, r9, 0x37)
[1371:6][c=0][uf=0] mov obf(0xcb10, r9, 0x16), obf(0xda82, r9, 0x24)
[1380:5][c=0][uf=0] mov obf(0xebb4, r9, 0x3c), obf(0xe20e, r9, 0x37)
[1389:4][c=0][uf=0] neg obf(0xebb4, r9, 0x3c)
[1394:6][c=0][uf=0] and obf(0xcb10, r9, 0x16), obf(0xebb4, r9, 0x3c)
[1403:5][c=0][uf=0] or obf(0xd5f8, r9, 0x25), obf(0xcb10, r9, 0x16)
[1412:4][c=0][uf=0] mov obf(0xc450, r9, 0x20), obf(0xd5f8, r9, 0x25)
[1421:3][c=0][uf=0] and obf(0xda82, r9, 0x24), obf(0xe20e, r9, 0x37)
[1430:2][c=0][uf=0] mov obf(0xe20e, r9, 0x37), obf(0xda82, r9, 0x24)
[1439:1][c=0][uf=0] mov obf(0xda82, r9, 0x24), obf(0xc450, r9, 0x20)
[1448:0][c=0][uf=1] shift left obf(0xe20e, r9, 0x37), 1
[1454:3][c=0][uf=0] or c obf(0xe1a6, r9, 0xb), 0xb929
[1462:0][c=0][uf=1] and obf(0xe20e, r9, 0x37), obf(0xe20e, r9, 0x37)
[1470:7][c=0][uf=0] jmp nz 1348:6
[1476:0][c=0][uf=0] neg obf(0xe1a6, r9, 0xb)
[1481:2][c=0][uf=1] shift left obf(0xe1a6, r9, 0xb), 1
[1487:5][c=0][uf=0] mov obf(0xead6, r9, 0x11), obf(0xda82, r9, 0x24)
[1496:4][c=0][uf=1] and obf(0xead6, r9, 0x11), obf(0xead6, r9, 0x11)
[1505:3][c=0][uf=0] jmp c 0695:5
[1510:4][c=0][uf=0] mov w[0x8000], 0xdead
[1517:1][c=0][uf=0] mov obf(0xcac6, r9, 0x34), r1
[1523:2][c=0][uf=0] and obf(0xcac6, r9, 0x34), r8
[1529:3][c=0][uf=0] mov w[0x8002], 0xbeef
[1536:0][c=0][uf=0] mov r0, 0x00aa
[1540:7][c=0][uf=0] mov r0, 0x00aa
[1545:6][c=0][uf=0] mov r0, 0x00aa
[1550:5][c=0][uf=0] mov r0, 0x00aa
[1555:4][c=0][uf=0] mov r0, 0x00aa
[1560:3][c=0][uf=0] mov r0, 0x00aa
[1565:2][c=0][uf=0] mov r0, 0x00aa
[1570:1][c=0][uf=0] mov r0, 0x00aa
[1575:0][c=0][uf=0] mov r0, 0x00aa
[1579:7][c=0][uf=0] mov r0, 0x00aa
[1584:6][c=0][uf=0] mov r0, 0x00aa
[1589:5][c=0][uf=0] mov r0, 0x00aa
[1594:4][c=0][uf=0] mov r0, 0x00aa
[1599:3][c=0][uf=0] mov r0, 0x00aa
[1604:2][c=0][uf=0] mov r0, 0x00aa
[1609:1][c=0][uf=0] mov r0, 0x00aa
[1614:0][c=0][uf=0] mov r0, 0x00aa
[1618:7][c=0][uf=0] mov r0, 0x00aa
[1623:6][c=0][uf=0] mov r0, 0x00aa
[1628:5][c=0][uf=0] mov r0, 0x00aa
[1633:4][c=0][uf=0] mov r0, 0x00aa
[1638:3][c=0][uf=0] mov r0, 0x00aa
[1643:2][c=0][uf=0] mov r0, 0x00aa
[1648:1][c=0][uf=0] mov r0, 0x00aa
[1653:0][c=0][uf=0] mov r0, 0x00aa
[1657:7][c=0][uf=0] mov r0, 0x00aa
[1662:6][c=0][uf=0] mov r0, 0x00aa
[1667:5][c=0][uf=0] mov r0, 0x00aa
[1672:4][c=0][uf=0] mov r0, 0x00aa
[1677:3][c=0][uf=0] mov r0, 0x00aa
[1682:2][c=0][uf=0] mov r0, 0x00aa
[1687:1][c=0][uf=0] mov r0, 0x00aa
[1692:0][c=0][uf=0] mov r0, 0x00aa
[1696:7][c=0][uf=0] mov r0, 0x00aa
[1701:6][c=0][uf=0] mov r0, 0x00aa
[1706:5][c=0][uf=0] mov r0, 0x00aa
[1711:4][c=0][uf=0] mov r0, 0x00aa
[1716:3][c=0][uf=0] mov r0, 0x00aa
[1721:2][c=0][uf=0] mov r0, 0x00aa
[1726:1][c=0][uf=0] mov r0, 0x00aa
[1731:0][c=0][uf=0] mov r0, 0x00aa
[1735:7][c=0][uf=0] mov r0, 0x00aa
[1740:6][c=0][uf=0] mov r0, 0x00aa
[1745:5][c=0][uf=0] mov r0, 0x00aa
[1750:4][c=0][uf=0] mov r0, 0x00aa
[1755:3][c=0][uf=0] jmp 0000:0
[1760:4][c=1][uf=0] and r0, r0
