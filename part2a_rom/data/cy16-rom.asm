


entrypoint_4000h:
// function binding: sp -> sp+2

// function ends at 401ch
    mov word ptr [0aah], 4076h                   ; @4000h  e7077640aa00  w2:0aah
    mov word ptr [0b4h], 0f756h                  ; @4006h  e70756f7b400  w2:0b4h
    mov r8, word_411ah                           ; @400ch  c8071a41  
    mov word ptr [r8++], 4000h                   ; @4010h  e0070040  overwritten by 40cch mov word ptr [r12++], word ptr [r8] ; r2:word_4054hw2:word_4010h w2:word_411ah
    mov word ptr [r8++], 0                       ; @4014h  e0070000  w2:word_411ch
    mov word ptr [r8++], 0                       ; @4018h  e0070000  w2:word_411eh
    ret                                          ; @401ch  97cf  endsub entrypoint_4000h
db 54 dup(0)                                     ; @401eh
word_4054h      dw 0fff1h                        ; @4054h addr:408ah addr:40aeh addr:41eah r2:40cch r2:4204h r2:4210h
db 0f2h, 0ffh, 0f3h, 0ffh, 0f4h, 0ffh, 0f5h, 0ffh ; @4056h
word_405eh      dw 0ffffh                        ; @405eh addr:41e6h r2:41f4h w2:41f4h
word_4060h      dw 0ffffh                        ; @4060h addr:41e6h r2:41feh r2:422ah r2:4246h w2:422ah w2:4246h
word_4062h      dw 0ffffh, 0ffffh, 0ffffh        ; @4062h addr:41e6h r2:423ch
word_4068h      dw 4000h                         ; @4068h addr:408ah addr:40aeh addr:4248h r2:408eh r2:40b2h w2:424ch
word_406ah      dw 4054h                         ; @406ah addr:408ah addr:40aeh addr:4248h r2:4090h r2:40c6h w2:424eh
word_406ch      dw 0                             ; @406ch addr:408ah w2:4096h
word_406eh      dw 0                             ; @406eh addr:408ah addr:40ceh addr:4248h r2:409ah r2:40d2h r2:40d6h
word_4070h      dw 0                             ; @4070h addr:408ah addr:40ceh r2:4262h w2:409ch w2:40d8h w2:44dah
word_4072h      dw 0                             ; @4072h addr:408ah addr:40ceh r1:4198h w2:409eh w2:40dah w2:418ah
word_4074h      dw 0                             ; @4074h addr:408ah addr:40ceh w2:40a2h w2:40dch


entrypoint_4076h:
// function binding: sp -> sp+2

// function ends at 40f4h, 40e6h, 40ach
    mov r0, byte ptr [r8 + 1]                    ; @4076h  000e0100  
    cmp r0, 51h                                  ; @407ah  c0575100  
    jz loc_408ah                                 ; @407eh  05c0  x:loc_408ah


    cmp r0, 56h                                  ; @4080h  c0575600  
    jz loc_40aeh                                 ; @4084h  14c0  x:loc_40aeh


    jmp loc_40e8h                                ; @4086h  9fcfe840  x:loc_40e8h



// Xrefs: 407eh
loc_408ah:
    mov r9, word_4068h                           ; @408ah  c9076840  
    mov r1, word ptr [r9++]                      ; @408eh  4108  r2:word_4068h
    mov r10, word ptr [r9++]                     ; @4090h  4a08  r2:word_406ah
    addi r8, 2                                   ; @4092h  48d8  
    mov word ptr [r10++], word ptr [r8++]        ; @4094h  2208  w2:word_4054h
    mov word ptr [r9++], word ptr [r8++]         ; @4096h  2108  w2:word_406ch
    mov r8, r9                                   ; @4098h  4802  
    xor word ptr [r9++], word ptr [r9]           ; @409ah  6194  r2:word_406eh w2:word_406eh
    mov word ptr [r9++], r1                      ; @409ch  6100  w2:word_4070h
    mov word ptr [r9++], 10h                     ; @409eh  e1071000  w2:word_4072h
    mov word ptr [r9++], 40f6h                   ; @40a2h  e107f640  w2:word_4074h
    mov r1, 8000h                                ; @40a6h  c1070080  
    int 51h                                      ; @40aah  51af  
    ret                                          ; @40ach  97cf  endsub entrypoint_4076h



// Xrefs: 4084h
loc_40aeh:
    mov r9, word_4068h                           ; @40aeh  c9076840  
    mov r1, word ptr [r9++]                      ; @40b2h  4108  r2:word_4068h
    mov r12, r1                                  ; @40b4h  4c00  
    add r12, 10h                                 ; @40b6h  cc171000  
    mov r10, word_4120h                          ; @40bah  ca072041  
    mov word ptr [r10++], r12                    ; @40beh  2203  w2:word_4120h
    mov word ptr [r10++], word ptr [r12]         ; @40c0h  2205  r2:word_4010h w2:word_4122h
    mov word ptr [r10++], word ptr [r12 + 2]     ; @40c2h  220d0200  r2:word_4012h w2:word_4124h
    mov r8, word ptr [r9++]                      ; @40c6h  4808  r2:word_406ah
    mov r3, 14h                                  ; @40c8h  c3071400  
    mov word ptr [r12++], word ptr [r8]          ; @40cch  2404  r2:word_4054h w2:word_4010h
    mov r9, word_406eh                           ; @40ceh  c9076e40  
    mov word ptr [r12], word ptr [r9]            ; @40d2h  5404  r2:word_406eh w2:word_4012h
    mov r8, r9                                   ; @40d4h  4802  
    xor word ptr [r9++], word ptr [r9]           ; @40d6h  6194  r2:word_406eh w2:word_406eh
    mov word ptr [r9++], r1                      ; @40d8h  6100  w2:word_4070h
    mov word ptr [r9++], r3                      ; @40dah  e100  w2:word_4072h
    mov word ptr [r9++], 40e8h                   ; @40dch  e107e840  w2:word_4074h
    mov r1, 8000h                                ; @40e0h  c1070080  
    int 50h                                      ; @40e4h  50af  
    ret                                          ; @40e6h  97cf  endsub entrypoint_4076h



// Xrefs: 4086h
loc_40e8h:
    int 59h                                      ; @40e8h  59af  
    mov r10, word_4120h                          ; @40eah  ca072041  
    mov r12, word ptr [r10++]                    ; @40eeh  8c08  r2:word_4120h
    mov word ptr [r12++], word ptr [r10++]       ; @40f0h  a408  r2:word_4122h w2:0
    mov word ptr [r12++], word ptr [r10++]       ; @40f2h  a408  r2:word_4124h w2:2
    ret                                          ; @40f4h  97cf  endsub entrypoint_4076h


entrypoint_40f6h:
    call loc_44dah                               ; @40f6h  9fafda44  noreturn x:loc_44dah



// Xrefs: 4266h
loc_40fah:
    int 59h                                      ; @40fah  59af  
    ret                                          ; @40fch  97cf  x:unknown
db 28 dup(0)                                     ; @40feh
word_411ah      dw 0                             ; @411ah addr:400ch addr:4254h addr:44deh addr:4686h addr:46c6h addr:47b6h
word_411ch      dw 0                             ; @411ch addr:400ch addr:4254h addr:44deh addr:4780h addr:47b6h addr:47e0h
word_411eh      dw 0                             ; @411eh addr:400ch addr:4254h addr:44deh r2:427ah r2:42a6h r2:42d4h
word_4120h      dw 0                             ; @4120h addr:40bah addr:40eah addr:4258h addr:44e2h r2:40eeh r2:425ch
word_4122h      dw 0                             ; @4122h addr:40bah addr:40eah addr:4258h addr:44e2h r2:40f0h r2:425eh
word_4124h      dw 0                             ; @4124h addr:40bah addr:40eah addr:4258h addr:44e2h r2:40f2h r2:4260h
word_4126h      dw 0                             ; @4126h addr:4348h r1:438ah r2:4354h r2:4382h r2:439ch r2:43b6h
word_4128h      dw 0                             ; @4128h r2:4418h r2:4612h w2:4402h w2:446eh w2:448ch w2:44b2h
word_412ah      dw 0                             ; @412ah r2:4422h r2:444ah r2:4474h r2:4648h r2:46d0h r2:46e6h
word_412ch      dw 0                             ; @412ch r2:46cah r2:46e2h r2:46f8h w2:4410h
word_412eh      dw 0                             ; @412eh addr:4680h addr:46c0h r1:4414h r1:4446h r1:4684h r1:46c4h
word_4130h      dw 0                             ; @4130h r1:460eh r2:4668h w2:43d8h
word_4132h      dw 0                             ; @4132h w2:4434h
word_4134h      dw 0                             ; @4134h addr:434ch r2:4580h w2:4354h
word_4136h      dw 0                             ; @4136h r2:4374h r2:4396h
word_4138h      dw 0                             ; @4138h r2:43a8h r2:43bah
word_413ah      dw 0                             ; @413ah r2:43a0h
byte_413ch      db 0, 0                          ; @413ch r1:4392h r1:43b2h
word_413eh      dw 0                             ; @413eh r2:435eh
word_4140h      dw 0                             ; @4140h r2:47aeh r2:4802h w2:46f8h
word_4142h      dw 0                             ; @4142h r2:47f0h r2:4806h w2:46f2h
word_4144h      dw 0                             ; @4144h addr:4592h r2:450ch r2:4596h r2:45a0h r2:482ah w2:45a8h



// Xrefs: 4290h 432ch 45f6h
sub_4146h:
// function binding: sp -> sp+2

// function ends at 4154h
    and r1, r1                                   ; @4146h  4160  
    jz loc_4154h                                 ; @4148h  05c0  x:loc_4154h



// Xrefs: 4152h
loc_414ah:
    shr r0, 1                                    ; @414ah  00d0  
    and r0, 7fffh                                ; @414ch  c067ff7f  
    subi r1, 1                                   ; @4150h  01da  
    jnz loc_414ah                                ; @4152h  7bc1  x:loc_414ah



// Xrefs: 4148h
loc_4154h:
    ret                                          ; @4154h  97cf  endsub sub_4146h



// Xrefs: 429ch 42deh 4314h 4338h 4600h
sub_4156h:
// function binding: sp -> sp+2

// function ends at 4160h
    and r1, r1                                   ; @4156h  4160  
    jz loc_4160h                                 ; @4158h  03c0  x:loc_4160h



// Xrefs: 415eh
loc_415ah:
    shl r0, 1                                    ; @415ah  00d2  
    subi r1, 1                                   ; @415ch  01da  
    jnz loc_415ah                                ; @415eh  7dc1  x:loc_415ah



// Xrefs: 4158h
loc_4160h:
    ret                                          ; @4160h  97cf  endsub sub_4156h



// Xrefs: 4288h 42ceh 42feh 4322h 444eh 468ch 469ah
loc_4162h:
    addi r1, 1                                   ; @4162h  01d8  
    shl r1, 1                                    ; @4164h  01d2  



// Xrefs: 4890h 43beh 47c8h 47d8h
loc_4166h:
    and r1, r1                                   ; @4166h  4160  
    jz loc_41a6h                                 ; @4168h  1ec0  x:loc_41a6h


    cmp r1, 2                                    ; @416ah  c1570200  
    jz loc_41a6h                                 ; @416eh  1bc0  x:loc_41a6h


    mov word ptr [sp], r0                        ; @4170h  1700  
    and r0, 0fh                                  ; @4172h  c0670f00  
    cmp r0, 0fh                                  ; @4176h  c0570f00  
    mov r0, word ptr [sp]                        ; @417ah  c005  
    jnz loc_41a6h                                ; @417ch  14c1  x:loc_41a6h


    shr r1, 1                                    ; @417eh  01d0  
    and r1, r1                                   ; @4180h  4160  
    jz loc_419eh                                 ; @4182h  0dc0  x:loc_419eh


    mov word ptr [sp], r0                        ; @4184h  1700  
    call loc_41a6h                               ; @4186h  9fafa641  noreturn x:loc_41a6h
    mov word ptr [word_4072h], r0                ; @418ah  27007240  w2:word_4072h
    mov r0, word ptr [sp]                        ; @418eh  c005  
    addi r0, 1                                   ; @4190h  00d8  
    call loc_41a6h                               ; @4192h  9fafa641  noreturn x:loc_41a6h


sub_4196h:
// function binding: sp -> sp+2

// function ends at 419ch
    shl r0, 8                                    ; @4196h  c0d3  
    and r0, byte ptr [word_4072h]                ; @4198h  c06b7240  r1:word_4072h
    ret                                          ; @419ch  97cf  endsub sub_4196h



// Xrefs: 4182h
loc_419eh:
    call loc_41a6h                               ; @419eh  9fafa641  noreturn x:loc_41a6h
    shr r2, 8                                    ; @41a2h  c2d1  
    addi r0, 1                                   ; @41a4h  00d8  



// Xrefs: 4168h 416eh 417ch 4186h 419eh 4192h
loc_41a6h:
    int 49h                                      ; @41a6h  49af  
    call sub_41dah                               ; @41a8h  9fafda41  x:sub_41dah
    mov word ptr [word_406eh], r0                ; @41ach  27006e40  w2:word_406eh
    int 4ah                                      ; @41b0h  4aaf  
    mov word ptr [sp], r8                        ; @41b2h  1702  
    mov r8, word ptr [word_406eh]                ; @41b4h  c8096e40  r2:word_406eh
    cmp r1, 2                                    ; @41b8h  c1570200  
    jae loc_41cah                                ; @41bch  06c3  x:loc_41cah


    and r1, r1                                   ; @41beh  4160  
    jz loc_41c6h                                 ; @41c0h  02c0  x:loc_41c6h


    mov word ptr [r8], r2                        ; @41c2h  9000  w2:unknown
    jmp loc_41d6h                                ; @41c4h  08cf  x:loc_41d6h



// Xrefs: 41c0h
loc_41c6h:
    mov byte ptr [r8], r2                        ; @41c6h  9800  w1:unknown
    jmp loc_41d6h                                ; @41c8h  06cf  x:loc_41d6h



// Xrefs: 41bch
loc_41cah:
    cmp r1, 4                                    ; @41cah  c1570400  
    jnz loc_41d4h                                ; @41ceh  02c1  x:loc_41d4h


    mov r0, word ptr [r8]                        ; @41d0h  0004  r2:unknown
    jmp loc_41d6h                                ; @41d2h  01cf  x:loc_41d6h



// Xrefs: 41ceh
loc_41d4h:
    mov r0, byte ptr [r8]                        ; @41d4h  0006  r1:unknown



// Xrefs: 41c4h 41c8h 41d2h
loc_41d6h:
    mov r8, word ptr [sp]                        ; @41d6h  c805  
    ret                                          ; @41d8h  97cf  x:word_4060h



// Xrefs: 41a8h
sub_41dah:
// function binding: r8 -> 4060h, sp -> sp+2

// function ends at 422ch
    mov r5, r0                                   ; @41dah  0500  
    and r5, 0fff0h                               ; @41dch  c567f0ff  
    mov r6, r1                                   ; @41e0h  4600  
    mov r7, 5                                    ; @41e2h  c7070500  
    mov r8, word_405eh                           ; @41e6h  c8075e40  
    mov r9, word_4054h                           ; @41eah  c9075440  
    mov r10, 4000h                               ; @41eeh  ca070040  
    int 49h                                      ; @41f2h  49af  



// Xrefs: 41f8h
loc_41f4h:
    addi word ptr [r8++], 1                      ; @41f4h  20d8  r2:word_405eh w2:word_405eh
    subi r7, 1                                   ; @41f6h  07da  
    jnz loc_41f4h                                ; @41f8h  7dc1  x:loc_41f4h


    int 4ah                                      ; @41fah  4aaf  
    mov r11, r8                                  ; @41fch  0b02  
    mov r1, word ptr [r8]                        ; @41feh  0104  r2:word_4060h
    mov r2, r9                                   ; @4200h  4202  
    mov r3, r10                                  ; @4202h  8302  



// Xrefs: 4244h
loc_4204h:
    mov r4, word ptr [r9]                        ; @4204h  4404  r2:word_4054h
    and r4, 1                                    ; @4206h  c4670100  
    jz loc_4210h                                 ; @420ah  02c0  x:loc_4210h


    mov r1, 0ffffh                               ; @420ch  c107ffff  



// Xrefs: 420ah
loc_4210h:
    mov r4, word ptr [r9++]                      ; @4210h  4408  r2:word_4054h
    and r4, 0fffeh                               ; @4212h  c467feff  
    cmp r5, r4                                   ; @4216h  0551  
    jnz loc_422eh                                ; @4218h  0ac1  x:loc_422eh


    subi r9, 2                                   ; @421ah  49da  
    and r6, 6                                    ; @421ch  c6670600  
    jnz loc_4226h                                ; @4220h  02c1  x:loc_4226h


    or word ptr [r9], 1                          ; @4222h  d1870100  r2:word_4054h w2:word_4054h



// Xrefs: 4220h
loc_4226h:
    sub r0, r5                                   ; @4226h  4031  
    add r0, r10                                  ; @4228h  8012  
    xor word ptr [r8], word ptr [r8]             ; @422ah  1094  r2:word_4060h w2:word_4060h
    ret                                          ; @422ch  97cf  endsub sub_41dah



// Xrefs: 4218h
loc_422eh:
    addi r8, 2                                   ; @422eh  48d8  
    add r10, 10h                                 ; @4230h  ca171000  
    subi r7, 1                                   ; @4234h  07da  
    jz loc_4246h                                 ; @4236h  07c0  x:loc_4246h


    cmp word ptr [r8], r1                        ; @4238h  5050  
    jb loc_4244h                                 ; @423ah  04c2  x:loc_4244h


    mov r1, word ptr [r8]                        ; @423ch  0104  r2:word_4062h
    mov r11, r8                                  ; @423eh  0b02  
    mov r2, r9                                   ; @4240h  4202  
    mov r3, r10                                  ; @4242h  8302  



// Xrefs: 423ah
loc_4244h:
    jmp loc_4204h                                ; @4244h  5fcf  x:loc_4204h



// Xrefs: 4236h
loc_4246h:
    xor word ptr [r11], word ptr [r11]           ; @4246h  d394  r2:word_4060h w2:word_4060h
    mov r10, word_4068h                          ; @4248h  ca076840  
    mov word ptr [r10++], r3                     ; @424ch  e200  w2:word_4068h
    mov word ptr [r10++], r2                     ; @424eh  a200  w2:word_406ah
    addi r10, 2                                  ; @4250h  4ad8  
    mov word ptr [r10++], r0                     ; @4252h  2200  w2:word_406eh
    mov r10, word_411ah                          ; @4254h  ca071a41  
    mov r11, word_4120h                          ; @4258h  cb072041  
    mov word ptr [r10++], word ptr [r11++]       ; @425ch  e208  r2:word_4120h w2:word_411ah
    mov word ptr [r10++], word ptr [r11++]       ; @425eh  e208  r2:word_4122h w2:word_411ch
    mov word ptr [r10++], word ptr [r11++]       ; @4260h  e208  r2:word_4124h w2:word_411eh
    mov sp, word ptr [word_4070h]                ; @4262h  cf097040  r2:word_4070h
    ret                                          ; @4266h  97cf  x:loc_40fah



// Xrefs: 44f0h 43c8h 43d4h 43f2h 4430h 44ach 44d2h 43feh ...
loc_4268h:
    int 49h                                      ; @4268h  49af  
    mov word ptr [sp], r0                        ; @426ah  1700  
    mov r10, r0                                  ; @426ch  0a00  
    xor r11, r11                                 ; @426eh  cb92  
    mov r14, 1                                   ; @4270h  ce070100  
    mov r13, 8                                   ; @4274h  cd070800  
    mov r5, r13                                  ; @4278h  4503  
    sub r5, word ptr [word_411eh]                ; @427ah  c5391e41  r2:word_411eh
    cmp r10, r5                                  ; @427eh  4a51  
    ja loc_42c8h                                 ; @4280h  23c8  x:loc_42c8h


    mov r1, r11                                  ; @4282h  c102  
    mov r0, word ptr [word_411ch]                ; @4284h  c0091c41  r2:word_411ch
    call loc_4162h                               ; @4288h  9faf6241  noreturn x:loc_4162h


sub_428ch:
// function binding: sp -> sp+2

// function ends at 42c6h
    mov r1, r5                                   ; @428ch  4101  
    sub r1, r10                                  ; @428eh  8132  
    call sub_4146h                               ; @4290h  9faf4641  x:sub_4146h
    mov r13, r0                                  ; @4294h  0d00  
    mov r1, r10                                  ; @4296h  8102  
    mov r0, 0ffffh                               ; @4298h  c007ffff  
    call sub_4156h                               ; @429ch  9faf5641  x:sub_4156h
    not r0                                       ; @42a0h  00de  
    and r0, r13                                  ; @42a2h  4063  



// Xrefs: 4342h
loc_42a4h:
    mov r10, word ptr [sp]                       ; @42a4h  ca05  
    mov r4, word ptr [word_411eh]                ; @42a6h  c4091e41  r2:word_411eh
    add r4, r10                                  ; @42aah  8412  
    mov r5, r4                                   ; @42ach  0501  
    shr r5, 3                                    ; @42aeh  85d0  
    and r5, 1fffh                                ; @42b0h  c567ff1f  
    add word ptr [word_411ch], r5                ; @42b4h  67111c41  r2:word_411ch w2:word_411ch
    and r4, 7                                    ; @42b8h  c4670700  
    mov word ptr [word_411eh], r4                ; @42bch  27011e41  w2:word_411eh
    mov word ptr [sp + 1ch], r0                  ; @42c0h  37001c00  
    int 4ah                                      ; @42c4h  4aaf  
    ret                                          ; @42c6h  97cf  endsub sub_428ch endsub sub_4326h



// Xrefs: 4280h
loc_42c8h:
    mov r1, r11                                  ; @42c8h  c102  
    mov r0, word ptr [word_411ch]                ; @42cah  c0091c41  r2:word_411ch
    call loc_4162h                               ; @42ceh  9faf6241  noreturn x:loc_4162h
    mov r12, r0                                  ; @42d2h  0c00  
    sub r13, word ptr [word_411eh]               ; @42d4h  cd391e41  r2:word_411eh
    mov r1, r13                                  ; @42d8h  4103  
    mov r0, 0ffffh                               ; @42dah  c007ffff  
    call sub_4156h                               ; @42deh  9faf5641  x:sub_4156h
    not r0                                       ; @42e2h  00de  
    and r12, r0                                  ; @42e4h  0c60  
    sub r10, r13                                 ; @42e6h  4a33  



// Xrefs: 430eh
loc_42e8h:
    cmp r10, 7                                   ; @42e8h  ca570700  
    jbe loc_4310h                                ; @42ech  11c9  x:loc_4310h


    shl r12, 8                                   ; @42eeh  ccd3  
    mov r5, word ptr [word_411ch]                ; @42f0h  c5091c41  r2:word_411ch
    add r5, r14                                  ; @42f4h  8513  
    xor r1, r1                                   ; @42f6h  4190  
    stX                                          ; @42f8h  c6df  
    jb loc_4310h                                 ; @42fah  0ac2  x:loc_4310h


    mov r0, r5                                   ; @42fch  4001  
    call loc_4162h                               ; @42feh  9faf6241  noreturn x:loc_4162h
    or r12, r0                                   ; @4302h  0c80  
    addi r14, 1                                  ; @4304h  0ed8  
    add r10, 0fff8h                              ; @4306h  ca17f8ff  
    xor r0, r0                                   ; @430ah  0090  
    stX                                          ; @430ch  c6df  
    jae loc_42e8h                                ; @430eh  6cc3  x:loc_42e8h



// Xrefs: 42ech 42fah
loc_4310h:
    mov r1, r10                                  ; @4310h  8102  
    mov r0, r12                                  ; @4312h  0003  
    call sub_4156h                               ; @4314h  9faf5641  x:sub_4156h
    mov r12, r0                                  ; @4318h  0c00  
    mov r0, word ptr [word_411ch]                ; @431ah  c0091c41  r2:word_411ch
    add r0, r14                                  ; @431eh  8013  
    xor r1, r1                                   ; @4320h  4190  
    call loc_4162h                               ; @4322h  9faf6241  noreturn x:loc_4162h


sub_4326h:
// function binding: sp -> sp+2

// function ends at 42c6h
    mov r1, 8                                    ; @4326h  c1070800  
    sub r1, r10                                  ; @432ah  8132  
    call sub_4146h                               ; @432ch  9faf4641  x:sub_4146h
    mov r13, r0                                  ; @4330h  0d00  
    mov r1, r10                                  ; @4332h  8102  
    mov r0, 0ffffh                               ; @4334h  c007ffff  
    call sub_4156h                               ; @4338h  9faf5641  x:sub_4156h
    not r0                                       ; @433ch  00de  
    and r0, r13                                  ; @433eh  4063  
    or r0, r12                                   ; @4340h  0083  
    jmp loc_42a4h                                ; @4342h  9fcfa442  x:loc_42a4h



// Xrefs: 4578h 45c2h 45e8h 464ch
sub_4346h:
// function binding: sp -> sp+2

// function ends at 435ch
    int 49h                                      ; @4346h  49af  
    mov r11, word_4126h                          ; @4348h  cb072641  
    mov r10, word_4134h                          ; @434ch  ca073441  
    mov r0, 6                                    ; @4350h  c0070600  



// Xrefs: 4358h
loc_4354h:
    mov word ptr [r10++], word ptr [r11++]       ; @4354h  e208  r2:word_4126h w2:word_4134h
    subi r0, 1                                   ; @4356h  00da  
    jnz loc_4354h                                ; @4358h  7dc1  x:loc_4354h


    int 4ah                                      ; @435ah  4aaf  
    ret                                          ; @435ch  97cf  endsub sub_4346h



// Xrefs: 45b6h
sub_435eh:
// function binding: sp -> sp+2

// function ends at 4372h
    mov r5, word ptr [word_413eh]                ; @435eh  c5093e41  r2:word_413eh
    cmp r5, 2                                    ; @4362h  c5570200  
    jz loc_43b2h                                 ; @4366h  25c0  x:loc_43b2h


    cmp r5, 3                                    ; @4368h  c5570300  
    jz loc_4392h                                 ; @436ch  12c0  x:loc_4392h


    and r5, r5                                   ; @436eh  4561  
    jz loc_4374h                                 ; @4370h  01c0  x:loc_4374h



// Xrefs: 4388h 4390h 43c2h
loc_4372h:
    ret                                          ; @4372h  97cf  endsub sub_435eh endsub sub_43c2h



// Xrefs: 4370h
loc_4374h:
    mov r9, word ptr [word_4136h]                ; @4374h  c9093641  r2:word_4136h
    shl r9, 1                                    ; @4378h  09d2  
    cmp word ptr [413ch], 0                      ; @437ah  e75700003c41  
    jz loc_438ah                                 ; @4380h  04c0  x:loc_438ah


    mov word ptr [r9 + 40feh], word ptr [word_4126h] ; @4382h  f1092641fe40  r2:word_4126h w2:unknown
    jmp loc_4372h                                ; @4388h  74cf  x:loc_4372h



// Xrefs: 4380h
loc_438ah:
    mov byte ptr [r9 + 40feh], byte ptr [word_4126h] ; @438ah  f90b2641fe40  r1:word_4126h w1:unknown
    jmp loc_4372h                                ; @4390h  70cf  x:loc_4372h



// Xrefs: 436ch
loc_4392h:
    mov r3, byte ptr [byte_413ch]                ; @4392h  c30b3c41  r1:byte_413ch
    mov r9, word ptr [word_4136h]                ; @4396h  c9093641  r2:word_4136h
    shl r9, 1                                    ; @439ah  09d2  
    mov r4, word ptr [word_4126h]                ; @439ch  c4092641  r2:word_4126h
    mov r2, word ptr [word_413ah]                ; @43a0h  c2093a41  r2:word_413ah
    mov r1, word ptr [r9 + 40feh]                ; @43a4h  410cfe40  r2:unknown
    mov r0, word ptr [word_4138h]                ; @43a8h  c0093841  r2:word_4138h
    call loc_484ch                               ; @43ach  9faf4c48  noreturn x:loc_484ch
db 60h, 0cfh                                     ; @43b0h



// Xrefs: 4366h
loc_43b2h:
    mov r1, byte ptr [byte_413ch]                ; @43b2h  c10b3c41  r1:byte_413ch
    mov r2, word ptr [word_4126h]                ; @43b6h  c2092641  r2:word_4126h
    mov r0, word ptr [word_4138h]                ; @43bah  c0093841  r2:word_4138h
    call loc_4166h                               ; @43beh  9faf6641  noreturn x:loc_4166h


sub_43c2h:
// function binding: sp -> sp+2

// function ends at 4372h
    jmp loc_4372h                                ; @43c2h  57cf  x:loc_4372h



// Xrefs: 4574h 460ah 45beh 457ch 45e4h 4650h 471ah
loc_43c4h:
    mov r0, 1                                    ; @43c4h  c0070100  
    call loc_4268h                               ; @43c8h  9faf6842  noreturn x:loc_4268h
    mov word ptr [word_412eh], r0                ; @43cch  27002e41  w2:word_412eh
    mov r0, 2                                    ; @43d0h  c0070200  
    call loc_4268h                               ; @43d4h  9faf6842  noreturn x:loc_4268h
    mov word ptr [word_4130h], r0                ; @43d8h  27003041  w2:word_4130h
    cmp r0, 1                                    ; @43dch  c0570100  
    jz loc_44c2h                                 ; @43e0h  9fc0c244  x:loc_44c2h


    jb loc_44a8h                                 ; @43e4h  9fc2a844  x:loc_44a8h


    cmp r0, 2                                    ; @43e8h  c0570200  
    jz loc_4430h                                 ; @43ech  21c0  x:loc_4430h


    mov r0, 10h                                  ; @43eeh  c0071000  
    call loc_4268h                               ; @43f2h  9faf6842  noreturn x:loc_4268h
    mov word ptr [word_412ah], r0                ; @43f6h  27002a41  w2:word_412ah
    mov r0, 4                                    ; @43fah  c0070400  
    call loc_4268h                               ; @43feh  9faf6842  noreturn x:loc_4268h
    mov word ptr [word_4128h], r0                ; @4402h  27002841  w2:word_4128h
    mov r0, 6                                    ; @4406h  c0070600  
    call loc_4268h                               ; @440ah  9faf6842  noreturn x:loc_4268h
    mov r2, r0                                   ; @440eh  0200  
    mov word ptr [word_412ch], r0                ; @4410h  27002c41  w2:word_412ch
    mov r3, byte ptr [word_412eh]                ; @4414h  c30b2e41  r1:word_412eh
    mov r9, word ptr [word_4128h]                ; @4418h  c9092841  r2:word_4128h
    shl r9, 1                                    ; @441ch  09d2  
    mov r1, word ptr [r9 + 40feh]                ; @441eh  410cfe40  r2:unknown
    mov r0, word ptr [word_412ah]                ; @4422h  c0092a41  r2:word_412ah
    call loc_4848h                               ; @4426h  9faf4848  noreturn x:loc_4848h



// Xrefs: 4452h 44d6h
sub_442ah:
// function binding: sp -> sp+2

// function ends at 442eh
    mov word ptr [word_4126h], r0                ; @442ah  27002641  w2:word_4126h



// Xrefs: 44beh
loc_442eh:
    ret                                          ; @442eh  97cf  endsub sub_442ah endsub sub_4452h endsub sub_44b0h endsub sub_44d6h



// Xrefs: 43ech
loc_4430h:
    call loc_4268h                               ; @4430h  9faf6842  noreturn x:loc_4268h
    mov word ptr [word_4132h], r0                ; @4434h  27003241  w2:word_4132h
    cmp r0, 1                                    ; @4438h  c0570100  
    jz loc_449ah                                 ; @443ch  2ec0  x:loc_449ah


    jb loc_4482h                                 ; @443eh  21c2  x:loc_4482h


    cmp r0, 2                                    ; @4440h  c0570200  
    jz loc_4454h                                 ; @4444h  07c0  x:loc_4454h



// Xrefs: 4480h 4498h 44a6h
loc_4446h:
    mov r1, byte ptr [word_412eh]                ; @4446h  c10b2e41  r1:word_412eh
    mov r0, word ptr [word_412ah]                ; @444ah  c0092a41  r2:word_412ah
    call loc_4162h                               ; @444eh  9faf6241  noreturn x:loc_4162h


sub_4452h:
// function binding: sp -> sp+2

// function ends at 442eh
    jmp sub_442ah                                ; @4452h  6bcf  x:sub_442ah



// Xrefs: 4444h
loc_4454h:
    mov r0, 10h                                  ; @4454h  c0071000  
    call loc_4268h                               ; @4458h  9faf6842  noreturn x:loc_4268h
    mov word ptr [word_412ah], r0                ; @445ch  27002a41  w2:word_412ah
    mov r0, 4                                    ; @4460h  c0070400  
    call loc_4268h                               ; @4464h  9faf6842  noreturn x:loc_4268h
    xor r1, r1                                   ; @4468h  4190  
    subi r1, 1                                   ; @446ah  01da  
    mov r9, r0                                   ; @446ch  0900  
    mov word ptr [word_4128h], r0                ; @446eh  27002841  w2:word_4128h
    add r9, r0                                   ; @4472h  0910  
    add word ptr [word_412ah], word ptr [r9 + 40feh] ; @4474h  671cfe402a41  r2:word_412ah w2:word_412ah
    add r1, 13h                                  ; @447ah  c1171300  
    ctX                                          ; @447eh  c7df  
    jbe loc_4446h                                ; @4480h  62c9  x:loc_4446h



// Xrefs: 443eh
loc_4482h:
    mov r0, 4                                    ; @4482h  c0070400  
    call loc_4268h                               ; @4486h  9faf6842  noreturn x:loc_4268h
    mov r9, r0                                   ; @448ah  0900  
    mov word ptr [word_4128h], r0                ; @448ch  27002841  w2:word_4128h
    add r9, r0                                   ; @4490h  0910  
    mov word ptr [word_412ah], word ptr [r9 + 40feh] ; @4492h  670cfe402a41  w2:word_412ah
    jmp loc_4446h                                ; @4498h  56cf  x:loc_4446h



// Xrefs: 443ch
loc_449ah:
    mov r0, 10h                                  ; @449ah  c0071000  
    call loc_4268h                               ; @449eh  9faf6842  noreturn x:loc_4268h
    mov word ptr [word_412ah], r0                ; @44a2h  27002a41  w2:word_412ah
    jmp loc_4446h                                ; @44a6h  4fcf  x:loc_4446h



// Xrefs: 43e4h
loc_44a8h:
    mov r0, 4                                    ; @44a8h  c0070400  
    call loc_4268h                               ; @44ach  9faf6842  noreturn x:loc_4268h


sub_44b0h:
// function binding: sp -> sp+2

// function ends at 442eh
    mov r9, r0                                   ; @44b0h  0900  
    mov word ptr [word_4128h], r0                ; @44b2h  27002841  w2:word_4128h
    add r9, r0                                   ; @44b6h  0910  
    mov word ptr [word_4126h], word ptr [r9 + 40feh] ; @44b8h  670cfe402641  w2:word_4126h
    jmp loc_442eh                                ; @44beh  9fcf2e44  x:loc_442eh



// Xrefs: 43e0h
loc_44c2h:
    mov r0, 10h                                  ; @44c2h  c0071000  
    cmp word ptr [412eh], 0                      ; @44c6h  e75700002e41  
    jnz loc_44d2h                                ; @44cch  02c1  x:loc_44d2h


    mov r0, 8                                    ; @44ceh  c0070800  



// Xrefs: 44cch
loc_44d2h:
    call loc_4268h                               ; @44d2h  9faf6842  noreturn x:loc_4268h


sub_44d6h:
// function binding: sp -> sp+2

// function ends at 442eh
    jmp sub_442ah                                ; @44d6h  9fcf2a44  x:sub_442ah



// Xrefs: 40f6h 456ah 45bah 465ah 46a2h 46feh 473eh 477ch ...
loc_44dah:
    mov word ptr [word_4070h], sp                ; @44dah  e7037040  w2:word_4070h
    mov r11, word_411ah                          ; @44deh  cb071a41  
    mov r10, word_4120h                          ; @44e2h  ca072041  
    mov word ptr [r10++], word ptr [r11++]       ; @44e6h  e208  r2:word_411ah w2:word_4120h
    mov word ptr [r10++], word ptr [r11++]       ; @44e8h  e208  r2:word_411ch w2:word_4122h
    mov word ptr [r10++], word ptr [r11++]       ; @44eah  e208  r2:word_411eh w2:word_4124h
    mov r0, 1                                    ; @44ech  c0070100  
    call loc_4268h                               ; @44f0h  9faf6842  noreturn x:loc_4268h
    mov r14, r0                                  ; @44f4h  0e00  
    and r14, 1                                   ; @44f6h  ce670100  
    mov r0, 8                                    ; @44fah  c0070800  
    call loc_4268h                               ; @44feh  9faf6842  noreturn x:loc_4268h


sub_4502h:
// function binding: sp -> sp+2

// function ends at 4812h
    cmp r0, 0ffh                                 ; @4502h  c057ff00  
    jz loc_4812h                                 ; @4506h  9fc01248  x:loc_4812h


    mov r11, r0                                  ; @450ah  0b00  
    mov r12, word ptr [word_4144h]               ; @450ch  cc094441  r2:word_4144h
    and r14, r14                                 ; @4510h  8e63  
    jnz loc_4518h                                ; @4512h  02c1  x:loc_4518h


    shr r11, 4                                   ; @4514h  cbd0  
    shr r12, 4                                   ; @4516h  ccd0  



// Xrefs: 4512h
loc_4518h:
    and r11, 0fh                                 ; @4518h  cb670f00  
    add r11, 0c0h                                ; @451ch  cb17c000  
    and r12, 0fh                                 ; @4520h  cc670f00  
    mov byte ptr [byte_4537h], r11               ; @4524h  ef023745  w1:byte_4537h
    mov r0, word ptr [0c000h]                    ; @4528h  c00900c0  r2:0c000h
    and r0, 0fff0h                               ; @452ch  c067f0ff  
    or r0, r12                                   ; @4530h  0083  
    mov word ptr [0c000h], r0                    ; @4532h  270000c0  w2:0c000h
    jae loc_453ah                                ; @4536h  01c3  x:loc_453ah


    addi r14, 2                                  ; @4538h  4ed8  



// Xrefs: 4536h
loc_453ah:
    xor r11, r11                                 ; @453ah  cb92  
    mov r0, 3                                    ; @453ch  c0070300  
    call loc_4268h                               ; @4540h  9faf6842  noreturn x:loc_4268h
    mov r13, r0                                  ; @4544h  0d00  
    mov r0, 1                                    ; @4546h  c0070100  
    call loc_4268h                               ; @454ah  9faf6842  noreturn x:loc_4268h
    mov r6, r0                                   ; @454eh  0600  
    mov word ptr [word_4126h], r11               ; @4550h  e7022641  w2:word_4126h
    cmp r13, 2                                   ; @4554h  cd570200  
    jz loc_45beh                                 ; @4558h  32c0  x:loc_45beh


    jb loc_4574h                                 ; @455ah  0cc2  x:loc_4574h


    cmp r13, 4                                   ; @455ch  cd570400  
    jz loc_460ah                                 ; @4560h  9fc00a46  x:loc_460ah


    jb loc_45d0h                                 ; @4564h  35c2  x:loc_45d0h


    cmp r13, 7                                   ; @4566h  cd570700  
    ja loc_44dah                                 ; @456ah  9fc8da44  x:loc_44dah


    stc                                          ; @456eh  c2df  
    jb loc_4702h                                 ; @4570h  9fc20247  x:loc_4702h



// Xrefs: 455ah
loc_4574h:
    call loc_43c4h                               ; @4574h  9fafc443  noreturn x:loc_43c4h
    call sub_4346h                               ; @4578h  9faf4643  x:sub_4346h
    call loc_43c4h                               ; @457ch  9fafc443  noreturn x:loc_43c4h
    mov r0, word ptr [word_4134h]                ; @4580h  c0093441  r2:word_4134h
    cmp r13, r11                                 ; @4584h  cd52  
    jz loc_458eh                                 ; @4586h  03c0  x:loc_458eh


    or r0, word ptr [word_4126h]                 ; @4588h  c0892641  r2:word_4126h
    jmp loc_4592h                                ; @458ch  02cf  x:loc_4592h



// Xrefs: 4586h
loc_458eh:
    and r0, word ptr [word_4126h]                ; @458eh  c0692641  r2:word_4126h



// Xrefs: 458ch
loc_4592h:
    mov r11, word_4144h                          ; @4592h  cb074441  
    mov r12, word ptr [r11]                      ; @4596h  cc04  r2:word_4144h
    call sub_4814h                               ; @4598h  9faf1448  x:sub_4814h
    and r12, 0ffeeh                              ; @459ch  cc67eeff  
    mov r2, word ptr [r11]                       ; @45a0h  c204  r2:word_4144h
    and r2, 0ff11h                               ; @45a2h  c26711ff  
    or r2, r12                                   ; @45a6h  0283  
    mov word ptr [r11], r2                       ; @45a8h  9300  w2:word_4144h



// Xrefs: 45feh 4608h
loc_45aah:
    mov word ptr [word_4126h], r0                ; @45aah  27002641  w2:word_4126h



// Xrefs: 45ceh 4664h 4678h 46b0h 46b8h
loc_45aeh:
    mov r12, r14                                 ; @45aeh  8c03  
    and r12, 2                                   ; @45b0h  cc670200  
    jnz loc_45bah                                ; @45b4h  02c1  x:loc_45bah


    call sub_435eh                               ; @45b6h  9faf5e43  x:sub_435eh



// Xrefs: 45b4h
loc_45bah:
    jmp loc_44dah                                ; @45bah  9fcfda44  x:loc_44dah



// Xrefs: 4558h
loc_45beh:
    call loc_43c4h                               ; @45beh  9fafc443  noreturn x:loc_43c4h
    call sub_4346h                               ; @45c2h  9faf4643  x:sub_4346h
    not word ptr [word_4126h]                    ; @45c6h  27de2641  r2:word_4126h w2:word_4126h
    call sub_4814h                               ; @45cah  9faf1448  x:sub_4814h
    jmp loc_45aeh                                ; @45ceh  6fcf  x:loc_45aeh



// Xrefs: 4564h
loc_45d0h:
    mov r0, 1                                    ; @45d0h  c0070100  
    call loc_4268h                               ; @45d4h  9faf6842  noreturn x:loc_4268h
    mov r10, r0                                  ; @45d8h  0a00  
    mov r0, 8                                    ; @45dah  c0070800  
    call loc_4268h                               ; @45deh  9faf6842  noreturn x:loc_4268h
    mov r12, r0                                  ; @45e2h  0c00  
    call loc_43c4h                               ; @45e4h  9fafc443  noreturn x:loc_43c4h
    call sub_4346h                               ; @45e8h  9faf4643  x:sub_4346h
    mov r1, r12                                  ; @45ech  0103  
    mov r0, word ptr [word_4126h]                ; @45eeh  c0092641  r2:word_4126h
    cmp r10, r11                                 ; @45f2h  ca52  
    jz loc_4600h                                 ; @45f4h  05c0  x:loc_4600h


    call sub_4146h                               ; @45f6h  9faf4641  x:sub_4146h
    call sub_4814h                               ; @45fah  9faf1448  x:sub_4814h
    jmp loc_45aah                                ; @45feh  55cf  x:loc_45aah



// Xrefs: 45f4h
loc_4600h:
    call sub_4156h                               ; @4600h  9faf5641  x:sub_4156h
    call sub_4814h                               ; @4604h  9faf1448  x:sub_4814h
    jmp loc_45aah                                ; @4608h  50cf  x:loc_45aah



// Xrefs: 4560h
loc_460ah:
    call loc_43c4h                               ; @460ah  9fafc443  noreturn x:loc_43c4h
    mov r4, byte ptr [word_4130h]                ; @460eh  c40b3041  r1:word_4130h
    mov r3, word ptr [word_4128h]                ; @4612h  c3092841  r2:word_4128h
    cmp r4, r11                                  ; @4616h  c452  
    jnz loc_4622h                                ; @4618h  04c1  x:loc_4622h


    cmp r3, 0fh                                  ; @461ah  c3570f00  
    jnz loc_4622h                                ; @461eh  01c1  x:loc_4622h


    addi r11, 1                                  ; @4620h  0bd8  



// Xrefs: 4618h 461eh
loc_4622h:
    cmp r3, 0eh                                  ; @4622h  c3570e00  
    jnz loc_464ch                                ; @4626h  12c1  x:loc_464ch


    cmp r4, 3                                    ; @4628h  c4570300  
    jz loc_463ch                                 ; @462ch  07c0  x:loc_463ch


    cmp r4, 2                                    ; @462eh  c4570200  
    jnz loc_464ch                                ; @4632h  0cc1  x:loc_464ch


    cmp word ptr [4132h], 0                      ; @4634h  e75700003241  
    jnz loc_464ch                                ; @463ah  08c1  x:loc_464ch



// Xrefs: 462ch
loc_463ch:
    mov r12, r14                                 ; @463ch  8c03  
    and r12, 2                                   ; @463eh  cc670200  
    jnz loc_464ch                                ; @4642h  04c1  x:loc_464ch


    subi word ptr [word_411ah], 2                ; @4644h  67da1a41  r2:word_411ah w2:word_411ah
    subi word ptr [word_412ah], 2                ; @4648h  67da2a41  r2:word_412ah w2:word_412ah



// Xrefs: 4626h 4632h 463ah 4642h
loc_464ch:
    call sub_4346h                               ; @464ch  9faf4643  x:sub_4346h
    call loc_43c4h                               ; @4650h  9fafc443  noreturn x:loc_43c4h
    mov r12, r14                                 ; @4654h  8c03  
    and r12, 2                                   ; @4656h  cc670200  
    jnz loc_44dah                                ; @465ah  9fc1da44  x:loc_44dah


    cmp word ptr [4128h], 0eh                    ; @465eh  e7570e002841  
    jnz loc_45aeh                                ; @4664h  9fc1ae45  x:loc_45aeh


    mov r5, word ptr [word_4130h]                ; @4668h  c5093041  r2:word_4130h
    cmp r5, 2                                    ; @466ch  c5570200  
    jnz loc_46b4h                                ; @4670h  21c1  x:loc_46b4h


    cmp word ptr [4132h], 0                      ; @4672h  e75700003241  
    jnz loc_45aeh                                ; @4678h  9fc1ae45  x:loc_45aeh


    and r11, r11                                 ; @467ch  cb62  
    jz loc_46a6h                                 ; @467eh  13c0  x:loc_46a6h


    mov r10, word_412eh                          ; @4680h  ca072e41  
    mov r1, byte ptr [r10]                       ; @4684h  8106  r1:word_412eh
    mov r12, word_411ah                          ; @4686h  cc071a41  
    mov r0, word ptr [r12]                       ; @468ah  0005  r2:word_411ah
    call loc_4162h                               ; @468ch  9faf6241  noreturn x:loc_4162h
    mov word ptr [word_411eh], r0                ; @4690h  27001e41  w2:word_411eh
    mov r0, word ptr [r12]                       ; @4694h  0005  
    addi r0, 2                                   ; @4696h  40d8  
    mov r1, byte ptr [r10]                       ; @4698h  8106  
    call loc_4162h                               ; @469ah  9faf6241  noreturn x:loc_4162h
    addi word ptr [r12++], 4                     ; @469eh  e4d8  
    mov word ptr [r12], r0                       ; @46a0h  1400  
    jmp loc_44dah                                ; @46a2h  9fcfda44  x:loc_44dah



// Xrefs: 467eh 46beh
loc_46a6h:
    addi word ptr [word_411ah], 2                ; @46a6h  67d81a41  r2:word_411ah w2:word_411ah
    clc                                          ; @46aah  c3df  
    stX                                          ; @46ach  c6df  
    jb loc_46b4h                                 ; @46aeh  02c2  x:loc_46b4h


    jmp loc_45aeh                                ; @46b0h  9fcfae45  x:loc_45aeh



// Xrefs: 4670h 46aeh
loc_46b4h:
    cmp r5, 3                                    ; @46b4h  c5570300  
    jnz loc_45aeh                                ; @46b8h  9fc1ae45  x:loc_45aeh


    and r11, r11                                 ; @46bch  cb62  
    jz loc_46a6h                                 ; @46beh  73c0  x:loc_46a6h


    mov r10, word_412eh                          ; @46c0h  ca072e41  
    mov r3, byte ptr [r10]                       ; @46c4h  8306  r1:word_412eh
    mov r12, word_411ah                          ; @46c6h  cc071a41  
    mov r2, word ptr [word_412ch]                ; @46cah  c2092c41  r2:word_412ch
    mov r1, word ptr [r12]                       ; @46ceh  0105  r2:word_411ah
    mov r0, word ptr [word_412ah]                ; @46d0h  c0092a41  r2:word_412ah
    call loc_4848h                               ; @46d4h  9faf4848  noreturn x:loc_4848h
    mov word ptr [word_411eh], r0                ; @46d8h  27001e41  w2:word_411eh
    mov r1, word ptr [r12]                       ; @46dch  0105  
    addi r1, 2                                   ; @46deh  41d8  
    mov r3, byte ptr [r10]                       ; @46e0h  8306  
    mov r2, word ptr [word_412ch]                ; @46e2h  c2092c41  r2:word_412ch
    mov r0, word ptr [word_412ah]                ; @46e6h  c0092a41  r2:word_412ah
    call loc_4848h                               ; @46eah  9faf4848  noreturn x:loc_4848h
    addi word ptr [r12++], 4                     ; @46eeh  e4d8  
    mov word ptr [r12], r0                       ; @46f0h  1400  
    mov word ptr [word_4142h], word ptr [word_412ah] ; @46f2h  e7092a414241  r2:word_412ah w2:word_4142h
    mov word ptr [word_4140h], word ptr [word_412ch] ; @46f8h  e7092c414041  r2:word_412ch w2:word_4140h
    jmp loc_44dah                                ; @46feh  9fcfda44  x:loc_44dah



// Xrefs: 4570h
loc_4702h:
    mov r0, 6                                    ; @4702h  c0070600  
    call loc_4268h                               ; @4706h  9faf6842  noreturn x:loc_4268h
    mov r12, r0                                  ; @470ah  0c00  
    mov r0, 3                                    ; @470ch  c0070300  
    call loc_4268h                               ; @4710h  9faf6842  noreturn x:loc_4268h
    mov r10, r0                                  ; @4714h  0a00  
    and r12, r12                                 ; @4716h  0c63  
    jnz loc_473ah                                ; @4718h  10c1  x:loc_473ah


    call loc_43c4h                               ; @471ah  9fafc443  noreturn x:loc_43c4h
    cmp word ptr [4130h], 1                      ; @471eh  e75701003041  
    jz loc_473ah                                 ; @4724h  0ac0  x:loc_473ah


    mov r5, word ptr [word_4126h]                ; @4726h  c5092641  r2:word_4126h
    mov r10, r5                                  ; @472ah  4a01  
    and r10, 7                                   ; @472ch  ca670700  
    shr r5, 3                                    ; @4730h  85d0  
    and r5, 1fffh                                ; @4732h  c567ff1f  
    mov word ptr [word_4126h], r5                ; @4736h  67012641  w2:word_4126h



// Xrefs: 4718h 4724h
loc_473ah:
    and r14, 2                                   ; @473ah  ce670200  
    jnz loc_44dah                                ; @473eh  9fc1da44  x:loc_44dah


    cmp r13, 6                                   ; @4742h  cd570600  
    jz loc_47aeh                                 ; @4746h  33c0  x:loc_47aeh



// Xrefs: 47dch 480eh
loc_4748h:
    and r12, r12                                 ; @4748h  0c63  
    jz loc_47a0h                                 ; @474ah  2ac0  x:loc_47a0h


    mov r11, r12                                 ; @474ch  0b03  
    and r11, 20h                                 ; @474eh  cb672000  
    and r12, 1fh                                 ; @4752h  cc671f00  
    and r11, r11                                 ; @4756h  cb62  
    jnz loc_4780h                                ; @4758h  13c1  x:loc_4780h


    mov r3, word ptr [word_411ch]                ; @475ah  c3091c41  r2:word_411ch
    add r3, r12                                  ; @475eh  0313  
    mov r4, word ptr [word_411eh]                ; @4760h  c4091e41  r2:word_411eh
    add r4, r10                                  ; @4764h  8412  
    mov r5, r4                                   ; @4766h  0501  
    shr r5, 3                                    ; @4768h  85d0  
    and r5, 1fffh                                ; @476ah  c567ff1f  
    add r3, r5                                   ; @476eh  4311  
    mov word ptr [word_411ch], r3                ; @4770h  e7001c41  w2:word_411ch
    and r4, 7                                    ; @4774h  c4670700  
    mov word ptr [word_411eh], r4                ; @4778h  27011e41  w2:word_411eh
    jmp loc_44dah                                ; @477ch  9fcfda44  x:loc_44dah



// Xrefs: 4758h
loc_4780h:
    mov r9, word_411ch                           ; @4780h  c9071c41  
    mov r0, word ptr [r9]                        ; @4784h  4004  r2:word_411ch
    sub r0, r12                                  ; @4786h  0033  
    mov r5, word ptr [word_411eh]                ; @4788h  c5091e41  r2:word_411eh
    cmp r5, r10                                  ; @478ch  8552  
    jae loc_4796h                                ; @478eh  03c3  x:loc_4796h


    subi r0, 1                                   ; @4790h  00da  
    addi word ptr [word_411eh], 8                ; @4792h  e7d91e41  r2:word_411eh w2:word_411eh



// Xrefs: 478eh
loc_4796h:
    mov word ptr [r9], r0                        ; @4796h  1100  w2:word_411ch
    sub word ptr [word_411eh], r10               ; @4798h  a7321e41  r2:word_411eh w2:word_411eh
    jmp loc_44dah                                ; @479ch  9fcfda44  x:loc_44dah



// Xrefs: 474ah
loc_47a0h:
    mov word ptr [word_411ch], word ptr [word_4126h] ; @47a0h  e70926411c41  r2:word_4126h w2:word_411ch
    mov word ptr [word_411eh], r10               ; @47a6h  a7021e41  w2:word_411eh
    jmp loc_44dah                                ; @47aah  9fcfda44  x:loc_44dah



// Xrefs: 4746h
loc_47aeh:
    mov r2, word ptr [word_4140h]                ; @47aeh  c2094041  r2:word_4140h
    and r2, r2                                   ; @47b2h  8260  
    jnz loc_47e0h                                ; @47b4h  15c1  x:loc_47e0h


    mov r13, word_411ah                          ; @47b6h  cd071a41  
    mov r9, r13                                  ; @47bah  4903  
    mov r5, word ptr [r13++]                     ; @47bch  4509  r2:word_411ah
    subi r5, 2                                   ; @47beh  45da  
    mov r2, word ptr [r13++]                     ; @47c0h  4209  r2:word_411ch
    mov r1, 1                                    ; @47c2h  c1070100  
    mov r0, r5                                   ; @47c6h  4001  
    call loc_4166h                               ; @47c8h  9faf6641  noreturn x:loc_4166h
    subi r5, 2                                   ; @47cch  45da  
    mov word ptr [r9], r5                        ; @47ceh  5101  
    mov r2, word ptr [r13]                       ; @47d0h  4205  
    mov r1, 1                                    ; @47d2h  c1070100  
    mov r0, r5                                   ; @47d6h  4001  
    call loc_4166h                               ; @47d8h  9faf6641  noreturn x:loc_4166h
    jmp loc_4748h                                ; @47dch  9fcf4847  x:loc_4748h



// Xrefs: 47b4h
loc_47e0h:
    mov r13, word_411ah                          ; @47e0h  cd071a41  
    mov r9, r13                                  ; @47e4h  4903  
    mov r1, word ptr [r13++]                     ; @47e6h  4109  r2:word_411ah
    subi r1, 2                                   ; @47e8h  41da  
    mov r3, 1                                    ; @47eah  c3070100  
    mov r4, word ptr [r13++]                     ; @47eeh  4409  r2:word_411ch
    mov r0, word ptr [word_4142h]                ; @47f0h  c0094241  r2:word_4142h
    call loc_484ch                               ; @47f4h  9faf4c48  noreturn x:loc_484ch
    subi r1, 2                                   ; @47f8h  41da  
    mov word ptr [r9], r1                        ; @47fah  5100  
    mov r3, 1                                    ; @47fch  c3070100  
    mov r4, word ptr [r13]                       ; @4800h  4405  
    mov r2, word ptr [word_4140h]                ; @4802h  c2094041  r2:word_4140h
    mov r0, word ptr [word_4142h]                ; @4806h  c0094241  r2:word_4142h
    call loc_484ch                               ; @480ah  9faf4c48  noreturn x:loc_484ch
    jmp loc_4748h                                ; @480eh  9fcf4847  x:loc_4748h



// Xrefs: 4506h
loc_4812h:
    ret                                          ; @4812h  97cf  endsub sub_4502h



// Xrefs: 4598h 45cah 45fah 4604h
sub_4814h:
// function binding: sp -> sp+2

// function ends at 4846h
    int 49h                                      ; @4814h  49af  
    mov r0, word ptr [0c000h]                    ; @4816h  c00900c0  r2:0c000h
    and r0, 0fh                                  ; @481ah  c0670f00  
    and r6, r6                                   ; @481eh  8661  
    jz loc_4844h                                 ; @4820h  11c0  x:loc_4844h


    mov r12, r14                                 ; @4822h  8c03  
    and r12, 2                                   ; @4824h  cc670200  
    jnz loc_4844h                                ; @4828h  0dc1  x:loc_4844h


    mov r12, word ptr [word_4144h]               ; @482ah  cc094441  r2:word_4144h
    and r14, r14                                 ; @482eh  8e63  
    jz loc_4838h                                 ; @4830h  03c0  x:loc_4838h


    and r12, 0f0h                                ; @4832h  cc67f000  
    jmp loc_483eh                                ; @4836h  03cf  x:loc_483eh



// Xrefs: 4830h
loc_4838h:
    shl r0, 4                                    ; @4838h  c0d2  
    and r12, 0fh                                 ; @483ah  cc670f00  



// Xrefs: 4836h
loc_483eh:
    or r12, r0                                   ; @483eh  0c80  
    mov word ptr [word_4144h], r12               ; @4840h  27034441  w2:word_4144h



// Xrefs: 4820h 4828h
loc_4844h:
    int 4ah                                      ; @4844h  4aaf  
    ret                                          ; @4846h  97cf  endsub sub_4814h



// Xrefs: 4426h 46d4h 46eah
loc_4848h:
    addi r3, 1                                   ; @4848h  03d8  
    shl r3, 1                                    ; @484ah  03d2  



// Xrefs: 43ach 47f4h 480ah
loc_484ch:
    int 49h                                      ; @484ch  49af  
    mov r5, r2                                   ; @484eh  8500  
    shl r5, 6                                    ; @4850h  45d3  
    add r5, r2                                   ; @4852h  8510  
    shl r5, 4                                    ; @4854h  c5d2  
    add r5, r2                                   ; @4856h  8510  
    xor r5, 464dh                                ; @4858h  c5974d46  
    mov r2, r0                                   ; @485ch  0200  
    xor r2, 6c38h                                ; @485eh  c297386c  
    add r0, r1                                   ; @4862h  4010  
    addi r1, 2                                   ; @4864h  41d8  



// Xrefs: 4884h
loc_4866h:
    mov r7, r6                                   ; @4866h  8701  
    rol r5, 1                                    ; @4868h  05d6  
    ror r2, 2                                    ; @486ah  42d4  
    add r2, r5                                   ; @486ch  4211  
    addi r5, 2                                   ; @486eh  45d8  
    mov r6, r2                                   ; @4870h  8600  
    xor r6, r5                                   ; @4872h  4691  
    mov r8, r6                                   ; @4874h  8801  
    shr r8, 8                                    ; @4876h  c8d1  
    and r8, 0ffh                                 ; @4878h  c867ff00  
    and r6, 0ffh                                 ; @487ch  c667ff00  
    xor r6, r8                                   ; @4880h  0692  
    subi r1, 1                                   ; @4882h  01da  
    jnz loc_4866h                                ; @4884h  70c1  x:loc_4866h


    shl r6, 8                                    ; @4886h  c6d3  
    or r6, r7                                    ; @4888h  c681  
    mov r1, r3                                   ; @488ah  c100  
    mov r2, r4                                   ; @488ch  0201  
    xor r2, r6                                   ; @488eh  8291  
    call loc_4166h                               ; @4890h  9faf6641  noreturn x:loc_4166h


sub_4894h:
// function binding: sp -> sp+2

// function ends at 48a6h
    xor r0, r6                                   ; @4894h  8091  
    and r3, 4                                    ; @4896h  c3670400  
    jnz loc_48a0h                                ; @489ah  02c1  x:loc_48a0h


    and r0, 0ffh                                 ; @489ch  c067ff00  



// Xrefs: 489ah
loc_48a0h:
    mov word ptr [sp + 1ch], r0                  ; @48a0h  37001c00  
    int 4ah                                      ; @48a4h  4aaf  
    ret                                          ; @48a6h  97cf  endsub sub_4894h
