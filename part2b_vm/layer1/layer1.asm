[0000:0][c=0][uf=0] mov r12, w[0xa000]
[0005:1][c=0][uf=0] mov r3, w[0xa002]
[0010:2][c=0][uf=0] mov r0, r12
[0013:5][c=0][uf=0] shift right r0, 8
[0017:2][c=0][uf=0] mov r13, r0
[0020:5][c=0][uf=0] and r13, r12
[0024:0][c=0][uf=0] mov w[0xe3b4], r0
[0029:1][c=0][uf=0] or w[0xe3b4], r12
[0034:2][c=0][uf=0] neg w[0xe3b4]
[0038:4][c=0][uf=0] or r13, w[0xe3b4]
[0043:5][c=0][uf=0] neg r13
[0046:1][c=0][uf=0] mov r6, r13
[0049:4][c=0][uf=0] mov r5, r6
[0052:7][c=0][uf=0] mov w[0xc7f2], 0x9577
[0059:4][c=0][uf=0] neg w[0xc7f2]
[0063:6][c=0][uf=0] or r5, w[0xc7f2]
[0068:7][c=0][uf=0] neg r5
[0071:3][c=0][uf=0] mov w[0xc882], r6
[0076:4][c=0][uf=0] mov w[0xf400], 0x9577
[0083:1][c=0][uf=0] neg w[0xf400]
[0087:3][c=0][uf=0] and w[0xc882], w[0xf400]
[0094:2][c=0][uf=0] or r5, w[0xc882]
[0099:3][c=0][uf=0] mov r6, r5
[0102:6][c=0][uf=0] mov r1, r3
[0106:1][c=0][uf=0] shift right r1, 8
[0109:6][c=0][uf=0] mov w[0xf31c], r1
[0114:7][c=0][uf=0] mov w[0xe99c], r3
[0120:0][c=0][uf=0] neg w[0xe99c]
[0124:2][c=0][uf=0] and w[0xf31c], w[0xe99c]
[0131:1][c=0][uf=0] mov r5, r1
[0134:4][c=0][uf=0] mov w[0xfc70], r3
[0139:5][c=0][uf=0] neg w[0xfc70]
[0143:7][c=0][uf=0] or r5, w[0xfc70]
[0149:0][c=0][uf=0] mov w[0xfc70], r5
[0154:1][c=0][uf=0] neg w[0xfc70]
[0158:3][c=0][uf=0] or w[0xf31c], w[0xfc70]
[0165:2][c=0][uf=0] mov r8, w[0xf31c]
[0170:3][c=0][uf=0] mov w[0xcac6], r12
[0175:4][c=0][uf=0] and w[0xcac6], 0x00ff
[0182:1][c=0][uf=0] mov r1, w[0xcac6]
[0187:2][c=0][uf=0] mov w[0xfe0c], r8
[0192:3][c=0][uf=0] and w[0xfe0c], r1
[0197:4][c=0][uf=0] mov r5, r8
[0200:7][c=0][uf=0] or r5, r1
[0204:2][c=0][uf=0] neg r5
[0206:6][c=0][uf=0] or w[0xfe0c], r5
[0211:7][c=0][uf=0] neg w[0xfe0c]
[0216:1][c=0][uf=0] mov r8, w[0xfe0c]
[0221:2][c=0][uf=0] mov w[0xe2ca], r1
[0226:3][c=0][uf=0] shift left w[0xe2ca], 8
[0231:6][c=0][uf=0] mov r1, w[0xe2ca]
[0236:7][c=0][uf=0] mov w[0xd68e], r8
[0242:0][c=0][uf=0] neg w[0xd68e]
[0246:2][c=0][uf=0] or w[0xd68e], r1
[0251:3][c=0][uf=0] neg w[0xd68e]
[0255:5][c=0][uf=0] mov w[0xd760], r8
[0260:6][c=0][uf=0] neg w[0xd760]
[0265:0][c=0][uf=0] and w[0xd760], r1
[0270:1][c=0][uf=0] or w[0xd68e], w[0xd760]
[0277:0][c=0][uf=0] mov r8, w[0xd68e]
[0282:1][c=0][uf=0] mov w[0xc1b4], r0
[0287:2][c=0][uf=0] shift left w[0xc1b4], 8
[0292:5][c=0][uf=0] mov r1, w[0xc1b4]
[0297:6][c=0][uf=0] mov w[0xda1e], r8
[0302:7][c=0][uf=0] or w[0xda1e], r1
[0308:0][c=0][uf=0] neg w[0xda1e]
[0312:2][c=0][uf=0] mov w[0xf26c], r8
[0317:3][c=0][uf=0] and w[0xf26c], r1
[0322:4][c=0][uf=0] or w[0xda1e], w[0xf26c]
[0329:3][c=0][uf=0] neg w[0xda1e]
[0333:5][c=0][uf=0] mov r8, w[0xda1e]
[0338:6][c=0][uf=0] mov r5, r8
[0342:1][c=0][uf=0] and r5, r0
[0345:4][c=0][uf=0] neg r5
[0348:0][c=0][uf=0] mov w[0xdd18], r8
[0353:1][c=0][uf=0] or w[0xdd18], r0
[0358:2][c=0][uf=0] and r5, w[0xdd18]
[0363:3][c=0][uf=0] mov r8, r5
[0366:6][c=0][uf=0] mov w[0xf9f8], r8
[0371:7][c=0][uf=0] mov w[0xfedc], 0xae4d
[0378:4][c=0][uf=0] neg w[0xfedc]
[0382:6][c=0][uf=0] mov r13, 0x1175
[0387:5][c=0][uf=0] mov w[0xc75e], 0x0001
[0394:2][c=0][uf=0] mov w[0xd89e], w[0xfedc]
[0401:1][c=0][uf=0] mov r5, w[0xc75e]
[0406:2][c=0][uf=0] neg r5
[0408:6][c=0][uf=0] or r5, w[0xd89e]
[0413:7][c=0][uf=0] mov w[0xd124], w[0xc75e]
[0420:6][c=0][uf=0] mov w[0xcf9a], w[0xd89e]
[0427:5][c=0][uf=0] neg w[0xcf9a]
[0431:7][c=0][uf=0] or w[0xd124], w[0xcf9a]
[0438:6][c=0][uf=0] and r5, w[0xd124]
[0443:7][c=0][uf=0] neg r5
[0446:3][c=0][uf=0] mov w[0xe5e2], r5
[0451:4][c=0][uf=0] and w[0xc75e], w[0xd89e]
[0458:3][c=0][uf=0] mov w[0xd89e], w[0xc75e]
[0465:2][c=0][uf=0] mov w[0xc75e], w[0xe5e2]
[0472:1][c=1][uf=1] shift left w[0xd89e], 1
[0477:4][c=1][uf=0] or c r13, 0x81a4
[0482:3][c=1][uf=1] and w[0xd89e], w[0xd89e]
[0489:2][c=1][uf=0] jmp nz 0401:1
[0494:3][c=0][uf=0] neg r13
[0496:7][c=1][uf=1] shift left r13, 1
[0500:4][c=0][uf=0] mov w[0xfedc], w[0xc75e]
[0507:3][c=0][uf=0] mov r5, 0x16b8
[0512:2][c=0][uf=0] mov w[0xd4ac], w[0xf9f8]
[0519:1][c=0][uf=0] mov w[0xcb26], w[0xfedc]
[0526:0][c=0][uf=0] mov w[0xdeb4], w[0xd4ac]
[0532:7][c=0][uf=0] neg w[0xdeb4]
[0537:1][c=0][uf=0] or w[0xdeb4], w[0xcb26]
[0544:0][c=0][uf=0] neg w[0xdeb4]
[0548:2][c=0][uf=0] mov w[0xf9e4], w[0xd4ac]
[0555:1][c=0][uf=0] neg w[0xf9e4]
[0559:3][c=0][uf=0] and w[0xf9e4], w[0xcb26]
[0566:2][c=0][uf=0] or w[0xdeb4], w[0xf9e4]
[0573:1][c=0][uf=0] mov r13, w[0xdeb4]
[0578:2][c=0][uf=0] and w[0xd4ac], w[0xcb26]
[0585:1][c=0][uf=0] mov w[0xcb26], w[0xd4ac]
[0592:0][c=0][uf=0] mov w[0xd4ac], r13
[0597:1][c=0][uf=1] shift left w[0xcb26], 1
[0602:4][c=0][uf=0] or c r5, 0xd8bf
[0607:3][c=0][uf=1] and w[0xcb26], w[0xcb26]
[0614:2][c=0][uf=0] jmp nz 0526:0
[0619:3][c=0][uf=0] neg r5
[0621:7][c=0][uf=1] shift left r5, 1
[0625:4][c=0][uf=0] mov w[0xf9f8], w[0xd4ac]
[0632:3][c=0][uf=1] and w[0xf9f8], w[0xf9f8]
[0639:2][c=0][uf=0] jmp nz 1376:0
[0644:3][c=0][uf=0] mov w[0xfa7a], 0x0539
[0651:0][c=0][uf=0] neg w[0xfa7a]
[0655:2][c=0][uf=0] mov w[0xdd8c], 0x0c9b
[0661:7][c=0][uf=0] mov w[0xcbd4], 0x0001
[0668:4][c=0][uf=0] mov w[0xf4ba], w[0xfa7a]
[0675:3][c=0][uf=0] mov w[0xea36], w[0xcbd4]
[0682:2][c=0][uf=0] mov w[0xe614], w[0xf4ba]
[0689:1][c=0][uf=0] neg w[0xe614]
[0693:3][c=0][uf=0] and w[0xea36], w[0xe614]
[0700:2][c=0][uf=0] mov r5, w[0xcbd4]
[0705:3][c=0][uf=0] mov w[0xf82e], w[0xf4ba]
[0712:2][c=0][uf=0] neg w[0xf82e]
[0716:4][c=0][uf=0] or r5, w[0xf82e]
[0721:5][c=0][uf=0] mov w[0xf82e], r5
[0726:6][c=0][uf=0] neg w[0xf82e]
[0731:0][c=0][uf=0] or w[0xea36], w[0xf82e]
[0737:7][c=0][uf=0] mov r13, w[0xea36]
[0743:0][c=0][uf=0] and w[0xcbd4], w[0xf4ba]
[0749:7][c=0][uf=0] mov w[0xf4ba], w[0xcbd4]
[0756:6][c=0][uf=0] mov w[0xcbd4], r13
[0761:7][c=0][uf=1] shift left w[0xf4ba], 1
[0767:2][c=0][uf=0] or c w[0xdd8c], 0xcd8e
[0773:7][c=0][uf=1] and w[0xf4ba], w[0xf4ba]
[0780:6][c=0][uf=0] jmp nz 0675:3
[0785:7][c=0][uf=0] neg w[0xdd8c]
[0790:1][c=0][uf=1] shift left w[0xdd8c], 1
[0795:4][c=0][uf=0] mov w[0xfa7a], w[0xcbd4]
[0802:3][c=0][uf=0] mov r13, 0x3167
[0807:2][c=0][uf=0] mov w[0xfbc0], r6
[0812:3][c=0][uf=0] mov w[0xf2ce], w[0xfa7a]
[0819:2][c=0][uf=0] mov r5, w[0xfbc0]
[0824:3][c=0][uf=0] mov w[0xdd4e], w[0xf2ce]
[0831:2][c=0][uf=0] neg w[0xdd4e]
[0835:4][c=0][uf=0] and r5, w[0xdd4e]
[0840:5][c=0][uf=0] mov w[0xc6c6], w[0xfbc0]
[0847:4][c=0][uf=0] neg w[0xc6c6]
[0851:6][c=0][uf=0] and w[0xc6c6], w[0xf2ce]
[0858:5][c=0][uf=0] or r5, w[0xc6c6]
[0863:6][c=0][uf=0] mov w[0xd1e4], r5
[0868:7][c=0][uf=0] and w[0xfbc0], w[0xf2ce]
[0875:6][c=0][uf=0] mov w[0xf2ce], w[0xfbc0]
[0882:5][c=0][uf=0] mov w[0xfbc0], w[0xd1e4]
[0889:4][c=1][uf=1] shift left w[0xf2ce], 1
[0894:7][c=1][uf=0] or c r13, 0xdcba
[0899:6][c=1][uf=1] and w[0xf2ce], w[0xf2ce]
[0906:5][c=1][uf=0] jmp nz 0819:2
[0911:6][c=0][uf=0] neg r13
[0914:2][c=1][uf=1] shift left r13, 1
[0917:7][c=0][uf=0] mov r6, w[0xfbc0]
[0923:0][c=0][uf=0] mov w[0xf2ce], r6
[0928:1][c=0][uf=0] mov w[0xd1e4], 0x6b14
[0934:6][c=0][uf=0] neg w[0xd1e4]
[0939:0][c=0][uf=0] mov w[0xe4ca], 0x6d7b
[0945:5][c=0][uf=0] mov w[0xc33c], 0x0001
[0952:2][c=0][uf=0] mov w[0xfb6a], w[0xd1e4]
[0959:1][c=0][uf=0] mov r5, w[0xc33c]
[0964:2][c=0][uf=0] neg r5
[0966:6][c=0][uf=0] or r5, w[0xfb6a]
[0971:7][c=0][uf=0] neg r5
[0974:3][c=0][uf=0] mov w[0xf16c], w[0xc33c]
[0981:2][c=0][uf=0] neg w[0xf16c]
[0985:4][c=0][uf=0] and w[0xf16c], w[0xfb6a]
[0992:3][c=0][uf=0] or r5, w[0xf16c]
[0997:4][c=0][uf=0] mov w[0xc2ce], r5
[1002:5][c=0][uf=0] and w[0xc33c], w[0xfb6a]
[1009:4][c=0][uf=0] mov w[0xfb6a], w[0xc33c]
[1016:3][c=0][uf=0] mov w[0xc33c], w[0xc2ce]
[1023:2][c=1][uf=1] shift left w[0xfb6a], 1
[1028:5][c=1][uf=0] or c w[0xe4ca], 0xa14f
[1035:2][c=1][uf=1] and w[0xfb6a], w[0xfb6a]
[1042:1][c=1][uf=0] jmp nz 0959:1
[1047:2][c=0][uf=0] neg w[0xe4ca]
[1051:4][c=1][uf=1] shift left w[0xe4ca], 1
[1056:7][c=0][uf=0] mov w[0xd1e4], w[0xc33c]
[1063:6][c=0][uf=0] mov w[0xe6ea], 0x4d27
[1070:3][c=0][uf=0] mov w[0xc9c8], w[0xf2ce]
[1077:2][c=0][uf=0] mov w[0xc82a], w[0xd1e4]
[1084:1][c=0][uf=0] mov w[0xc71e], w[0xc9c8]
[1091:0][c=0][uf=0] or w[0xc71e], w[0xc82a]
[1097:7][c=0][uf=0] mov r5, w[0xc9c8]
[1103:0][c=0][uf=0] and r5, w[0xc82a]
[1108:1][c=0][uf=0] neg r5
[1110:5][c=0][uf=0] and w[0xc71e], r5
[1115:6][c=0][uf=0] mov r13, w[0xc71e]
[1120:7][c=0][uf=0] and w[0xc9c8], w[0xc82a]
[1127:6][c=0][uf=0] mov w[0xc82a], w[0xc9c8]
[1134:5][c=0][uf=0] mov w[0xc9c8], r13
[1139:6][c=0][uf=1] shift left w[0xc82a], 1
[1145:1][c=0][uf=0] or c w[0xe6ea], 0xd149
[1151:6][c=0][uf=1] and w[0xc82a], w[0xc82a]
[1158:5][c=0][uf=0] jmp nz 1084:1
[1163:6][c=0][uf=0] neg w[0xe6ea]
[1168:0][c=0][uf=1] shift left w[0xe6ea], 1
[1173:3][c=0][uf=0] mov w[0xf2ce], w[0xc9c8]
[1180:2][c=0][uf=1] and w[0xf2ce], w[0xf2ce]
[1187:1][c=0][uf=0] mov z w[0xfd20], 0x084c
[1193:6][c=0][uf=0] mov z w[0xc1a4], 0xdead
[1200:3][c=0][uf=0] mov z w[0xd568], r8
[1205:4][c=0][uf=0] mov z w[0xd800], w[0xc1a4]
[1212:3][c=0][uf=0] neg z w[0xd800]
[1216:5][c=0][uf=0] or z w[0xd800], w[0xd568]
[1223:4][c=0][uf=0] neg z w[0xd800]
[1227:6][c=0][uf=0] mov z w[0xe6b8], w[0xc1a4]
[1234:5][c=0][uf=0] neg z w[0xe6b8]
[1238:7][c=0][uf=0] and z w[0xe6b8], w[0xd568]
[1245:6][c=0][uf=0] or z w[0xd800], w[0xe6b8]
[1252:5][c=0][uf=0] mov z w[0xf0da], w[0xd800]
[1259:4][c=0][uf=0] and z w[0xc1a4], w[0xd568]
[1266:3][c=0][uf=0] mov z w[0xd568], w[0xc1a4]
[1273:2][c=0][uf=0] mov z w[0xc1a4], w[0xf0da]
[1280:1][c=1][uf=1] shift left w[0xd568], 1
[1285:4][c=1][uf=0] or c w[0xfd20], 0xb4fd
[1292:1][c=1][uf=1] and w[0xd568], w[0xd568]
[1299:0][c=0][uf=0] jmp nz 1306:7
[1301:6][c=1][uf=0] jmp nz 1205:4
[1306:7][c=0][uf=0] neg w[0xfd20]
[1311:1][c=1][uf=1] shift left w[0xfd20], 1
[1316:4][c=0][uf=0] mov z w[0xa000], w[0xc1a4]
[1323:3][c=0][uf=0] mov z w[0xdfd0], r6
[1328:4][c=0][uf=0] mov z w[0xe738], 0xbeef
[1335:1][c=0][uf=0] neg z w[0xe738]
[1339:3][c=0][uf=0] and z w[0xdfd0], w[0xe738]
[1346:2][c=0][uf=0] mov z w[0xd25c], r6
[1351:3][c=0][uf=0] neg z w[0xd25c]
[1355:5][c=0][uf=0] and z w[0xd25c], 0xbeef
[1362:2][c=0][uf=0] or z w[0xdfd0], w[0xd25c]
[1369:1][c=0][uf=0] mov z w[0xa002], w[0xdfd0]
[1376:0][c=0][uf=0] mov w[0xcb1e], r1
[1381:1][c=0][uf=0] or w[0xcb1e], r1
[1386:2][c=0][uf=0] mov w[0x8000], 0xdead
[1392:7][c=0][uf=0] mov w[0x8002], 0xbeef
[1399:4][c=0][uf=0] mov r0, 0x00aa
[1404:3][c=0][uf=0] mov r0, 0x00aa
[1409:2][c=0][uf=0] mov r0, 0x00aa
[1414:1][c=0][uf=0] mov r0, 0x00aa
[1419:0][c=0][uf=0] mov r0, 0x00aa
[1423:7][c=0][uf=0] mov r0, 0x00aa
[1428:6][c=0][uf=0] mov r0, 0x00aa
[1433:5][c=0][uf=0] mov r0, 0x00aa
[1438:4][c=0][uf=0] mov r0, 0x00aa
[1443:3][c=0][uf=0] mov r0, 0x00aa
[1448:2][c=0][uf=0] mov r0, 0x00aa
[1453:1][c=0][uf=0] mov r0, 0x00aa
[1458:0][c=0][uf=0] mov r0, 0x00aa
[1462:7][c=0][uf=0] mov r0, 0x00aa
[1467:6][c=0][uf=0] mov r0, 0x00aa
[1472:5][c=0][uf=0] mov r0, 0x00aa
[1477:4][c=0][uf=0] mov r0, 0x00aa
[1482:3][c=0][uf=0] mov r0, 0x00aa
[1487:2][c=0][uf=0] mov r0, 0x00aa
[1492:1][c=0][uf=0] mov r0, 0x00aa
[1497:0][c=0][uf=0] mov r0, 0x00aa
[1501:7][c=0][uf=0] mov r0, 0x00aa
[1506:6][c=0][uf=0] mov r0, 0x00aa
[1511:5][c=0][uf=0] mov r0, 0x00aa
[1516:4][c=0][uf=0] mov r0, 0x00aa
[1521:3][c=0][uf=0] mov r0, 0x00aa
[1526:2][c=0][uf=0] mov r0, 0x00aa
[1531:1][c=0][uf=0] mov r0, 0x00aa
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
[1618:7][c=0][uf=0] jmp 0000:0
[1624:0][c=1][uf=0] and r0, r0
