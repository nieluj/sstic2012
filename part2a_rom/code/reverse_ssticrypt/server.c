/* vim: set noet foldmethod=marker ts=4 sw=4: */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <setjmp.h>
#include <string.h>
#include <strings.h>
#include <assert.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>

#include "utils.h"
#include "server.h"

/* data */
uint8_t *m = NULL;
uint8_t *from_client = NULL;
jmp_buf env;

#define ROM_PATH  DATA_PATH "stage2_rom_scan_record_0.relocated"

#define UNUSED 0

#define OFF_ADDR     0x406a
#define SAVED_INDEX  0x406c
#define BUF_ADDR     0x4068
#define NEW_OFF_SRC  0x406e

#define SAVED_OFF_ADDR 0x4120
#define SAVED_OFF_DEST 0x4122
#define SAVED_OFF_SRC  0x4124

#define CURRENT_BYTE 0x411c
#define CURRENT_BITS 0x411e

#define OP_MEMREF_TYPE 0x4132

#define SRC_VALUE     0x4126
#define SRC_REG       0x4128
#define SRC_MEM_ADDR  0x412a
#define SRC_OBF_VALUE 0x412c
#define SRC_SIZE      0x412e
#define SRC_TYPE      0x4130

#define DST_VALUE     0x4134
#define DST_REG       0x4136
#define DST_MEM_ADDR  0x4138
#define DST_OBF_VALUE 0x413a
#define DST_SIZE      0x413c
#define DST_TYPE      0x413e

char *op_types[] = { "REG", "IMM", "MEMREF", "OBF" };

char *instructions[] = { "and", "or", "neg", "shift", "mov", "jmp5", "jmp6", "jmp7" };

#define OP_TYPE_REG       0
#define OP_TYPE_IMMEDIATE 1
#define OP_TYPE_MEMREF    2
#define OP_TYPE_OBF       3

#define FLAGS 0x4144
#define REG_BASE 0x40fe

#define COND_MATCHED(v) ( ( ((v) & 2) == 0) )
#define READ_REG(v) (rw(REG_BASE + 2 * (v)))

#define DO_SET_BYTE 0
#define DO_SET_WORD 1
#define DO_GET_BYTE 2
#define DO_GET_WORD 4

/*{{{asm init
  4000h mov word ptr [0aah], 4076h  ; w00aa = 0x4076
  4006h mov word ptr [0b4h], 0f756h ; w00b4 = 0xf756
  400ch mov r8, 411ah
  4010h mov word ptr [r8++], 4000h  ; word_411ah = 0x4000
  4014h mov word ptr [r8++], 0      ; w11c = 0
  4018h mov word ptr [r8++], 0      ; w11e = 0
  401ch ret
  asm}}}*/

#define ZF(v) ( ((v) >> 0) & 1 )
#define CF(v) ( ((v) >> 1) & 1 )
#define OF(v) ( ((v) >> 2) & 1 )
#define SF(v) ( ((v) >> 3) & 1 )

static inline int test_flags(uint16_t r11, uint16_t r12) {
  //debug(INFO, "cond = %x, flags = %x", r11, r12);
  switch(r11) {
    case 0:
      return ZF(r12) == 1;
    case 1:
      return ZF(r12) == 0;
    case 2:
      return CF(r12) == 1;
    case 3:
      return CF(r12) == 0;
    case 4:
      return SF(r12) == 1;
    case 5:
      return SF(r12) == 0;
    case 6:
      return OF(r12) == 1;
    case 7:
      return OF(r12) == 0;
    case 8:
      return (ZF(r12) == 0) && (CF(r12) == 0);
    case 9:
      return (ZF(r12) == 1) || (CF(r12) == 1);
    case 10:
      return (OF(r12) == SF(r12)) && (ZF(r12) == 0);
    case 11:
      return OF(r12) == SF(r12);
    case 12:
      return OF(r12) != SF(r12);
    case 13:
      return (OF(r12) != SF(r12)) || (ZF(r12) == 1);
    case 15:
      return 1;
    default:
      printf("wtf!!\n");
      return 0;
  }
}

static inline void update_flags(uint16_t zero, int carry, int sign) {
  uint16_t v = 0;
  if (zero == 1)
    v = 1;

  if (carry == 1)
    v |= (1 << 1);

  if (sign == 1)
    v |= (1 << 3);

  sw(0xc000, v);
}

void do_mem_init(void) {
  if (!m)
    m = calloc(MEM_SIZE, 1);
  else
    clear_mem();

  if (!from_client)
    from_client = calloc(20, 1);
}

void clear_mem(void) {
  bzero(m, MEM_SIZE);
}
void do_server_init(void) {
	char *addr;
	int fd, i;
	struct stat sb;

	do_mem_init();

	fd = open(ROM_PATH, O_RDONLY);
	if (fd == -1)
		handle_error("open");

	if (fstat(fd, &sb) == -1)
		handle_error("fstat");

	addr = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (addr == MAP_FAILED)
		handle_error("mmap");
	close(fd);

	for (i = 0; i < sb.st_size; i++)
		m[0x4000 + i] = addr[i];

	munmap(addr, sb.st_size);

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
	sw(BUF_ADDR, 0x4000);
	sw(OFF_ADDR, 0x4054);

	sw(0x00aa, 0x4076);
	sw(0x00b4, 0xf756);

	sw(0x411a, 0x4000);
	sw(CURRENT_BYTE, 0);
	sw(CURRENT_BITS, 0);
}

/*{{{asm susb_vendor_int done
  4076h mov r0, byte ptr [r8 + 1]             ; r8 = 0x300, r0 = b[0x301] (request)
  407ah cmp r0, 51h                           ; b[0x301] == 0x51 ?
  407eh jz loc_408ah ; x:loc_408ah            ; saute si oui
  4080h cmp r0, 56h                           ; b[0x301] == 0x56
  4084h jz loc_40aeh ; x:loc_40aeh            ; saute si oui
  4086h jmp loc_40e8h ; x:loc_40e8h           ; saute sinon

  408ah mov r9, 4068h                         ; r9  = BUF_ADDR
  408eh mov r1, word ptr [r9++]               ; r1  = w[BUF_ADDR], r9 = OFF_ADDR
  4090h mov r10, word ptr [r9++]              ; r10 = w[OFF_ADDR], r9 = 0x406c
  4092h addi r8, 2                            ; r8  = 0x302
  4094h mov word ptr [r10++], word ptr [r8++] ; w[w[OFF_ADDR]] = w[0x302] (value), r10 = w[OFF_ADDR] + 2, r8 = 0x304
  4096h mov word ptr [r9++], word ptr [r8++]  ; w[0x406c] = w[0x304] (index), r9 = NEW_OFF_DEST
  4098h mov r8, r9                            ; r8 = NEW_OFF_DEST
  409ah xor word ptr [r9++], word ptr [r9]    ; w[NEW_OFF_DEST] = 0, r9 = 0x4070
  409ch mov word ptr [r9++], r1               ; w[0x4070] = w[BUF_ADDR]
  409eh mov word ptr [r9++], 10h              ; w[0x4072] = 16
  40a2h mov word ptr [r9++], 40f6h            ; w[0x4074] = 0x40f6
  40a6h mov r1, 8000h                         ; r1 = 0x8000
  40aah int 51h
  40ach ret

  40aeh mov r9, 4068h                             ; r9  = BUF_ADDR
  40b2h mov r1, word ptr [r9++]                   ; r1  = w[BUF_ADDR], r9 = OFF_ADDR
  40b4h mov r12, r1                               ; r12 = w[BUF_ADDR]
  40b6h add r12, 10h                              ; r12 = w[BUF_ADDR] + 16
  40bah mov r10, 4120h                            ; r10 = SAVED_OFF_ADDR
  40beh mov word ptr [r10++], r12                 ; w[SAVED_OFF_ADDR] = w[BUF_ADDR] + 16,          r10 = SAVED_OFF_SRC
  40c0h mov word ptr [r10++], word ptr [r12]      ; w[SAVED_OFF_SRC] = w[ w[BUF_ADDR] + 16 ],     r10 = SAVED_OFF_DEST
  40c2h mov word ptr [r10++], word ptr [r12 + 2]  ; w[SAVED_OFF_DEST] = w[ w[BUF_ADDR] + 16 + 2 ], r10 = SRC_VALUE
  40c6h mov r8, word ptr [r9++]                   ; r8 = w[OFF_ADDR], r9 = 0x406c
  40c8h mov r3, 14h                               ; r3 = 0x14
  40cch mov word ptr [r12++], word ptr [r8]       ; w[ w[BUF_ADDR] + 16 ] = w[ w[OFF_ADDR] ], r12 = w[BUF_ADDR] + 16 + 2
  40ceh mov r9, 406eh                             ; r9 = NEW_OFF_DEST
  40d2h mov word ptr [r12], word ptr [r9]         ; w[ w[BUF_ADDR] + 16 + 2 ] = w[NEW_OFF_DEST]
  40d4h mov r8, r9                                ; r8 = NEW_OFF_DEST
  40d6h xor word ptr [r9++], word ptr [r9]        ; w[NEW_OFF_DEST] = 0, r9 = 0x4070
  40d8h mov word ptr [r9++], r1                   ; w[0x4070] = w[BUF_ADDR]
  40dah mov word ptr [r9++], r3                   ; w[0x4072] = 16
  40dch mov word ptr [r9++], 40e8h                ; w[0x4074] = 0x40e8
  40e0h mov r1, 8000h                             ; r1 = 0x8000
  40e4h int 50h
  40e6h ret
  asm}}}*/

// 408ah
void handle_receive_req(struct usb_req *req) {
  struct endpoint_desc ep0;

  /* update the first offset with the current src offset */
  sw(rw(OFF_ADDR), req->value);
  sw(SAVED_INDEX, req->index);

  ep0.nextlink = 0;
  ep0.address  = rw(BUF_ADDR);
  ep0.length   = 16;
  ep0.callback = susb1_receive_int_callback;

  do_susb1_receive_int(&ep0);
}

void handle_send_req(struct usb_req *req) {
  uint16_t r8, r12;
  struct endpoint_desc ep0;

  /* r12 pointe sur la fin du buffer de données */
  r12 = rw(BUF_ADDR) + 16;

  debug(DEBUG, "BUF_ADDR = 0x%04x, SAVED_OFF_ADDR <- 0x%04x, SAVED_OFF_DEST <- 0x%04x, SAVED_OFF_SRC <- 0x%04x",
      rw(BUF_ADDR), r12, rw(r12), rw(r12 + 2));

  sw(SAVED_OFF_ADDR, r12);
  sw(SAVED_OFF_DEST, rw(r12));       /* premier offset */
  sw(SAVED_OFF_SRC, rw(r12 + 2));   /* 2e offset */

  sw(r12,     rw(rw(OFF_ADDR)));
  sw(r12 + 2, rw(NEW_OFF_SRC));

  debug(DEBUG, "NEW_OFF_DEST <- 0x%04x, NEW_OFF_SRC <- 0x%04x",
      rw((rw(OFF_ADDR))), rw(NEW_OFF_SRC));

  ep0.nextlink = 0;
  ep0.address  = rw(BUF_ADDR);
  ep0.length   = 20;
  ep0.callback = sub_40e8;

  do_susb1_send_int(&ep0);
}

/* TODO : set the endpoint structure after calling the callback */
int do_susb1_receive_int(struct endpoint_desc *ep) {
  bin_to_hex(hexbuf, (char *) from_client, ep->length);
  debug(INFO, "0x%04x <- %s", ep->address, hexbuf);
  memcpy(m + ep->address, from_client, ep->length);
  ep->callback(ep);
  return 0;
}

/* TODO : set the endpoint structure after calling the callback */
int do_susb1_send_int(struct endpoint_desc *ep) {
  bin_to_hex(hexbuf, (char *) m + ep->address, ep->length);
  debug(INFO, "0x%04x -> %s", ep->address, hexbuf);
  memcpy(from_client, m + ep->address, ep->length);
  ep->callback(ep);
  return 0;
}

void do_susb1_finish_int(void) {
  // TODO
}

// 0x40f6
void handle_usb_vendor_int(struct usb_req *req) {
  if (req->request == 0x51) {
    handle_receive_req(req); // 408ah
  } else if (req->request == 0x56) {
    handle_send_req(req);  // 40aeh
  } else {
    do_susb1_finish_int(); // 4068h
  }
}

/*{{{asm int_50_callback
  40e8h int 59h
  40eah mov r10, 4120h                            ; r10 = SAVED_OFF_ADDR
  40eeh mov r12, word ptr [r10++]                 ; r12 = w[SAVED_OFF_ADDR], r10 = SAVED_OFF_SRC
  40f0h mov word ptr [r12++], word ptr [r10++]    ; w[ w[SAVED_OFF_ADDR] ]     = w[SAVED_OFF_SRC]
  40f2h mov word ptr [r12++], word ptr [r10++]    ; w[ w[SAVED_OFF_ADDR] + 2 ] =  w[SAVED_OFF_DEST]
  40f4h ret
  asm}}}*/
//void susb1_send_int_callback(struct endpoint_desc *ep) {
void sub_40e8(struct endpoint_desc *ep) {

  uint16_t r12;
  do_susb1_finish_int();

  r12 = rw(SAVED_OFF_ADDR);
  sw(r12,     rw(SAVED_OFF_DEST));
  sw(r12 + 2, rw(SAVED_OFF_SRC));
}

/*{{{asm int_51_callback
  40f6h call sub_44dah ; x:sub_44dah
  40fah int 59h
  40fch ret
  asm}}}*/
void susb1_receive_int_callback(struct endpoint_desc *ep) {
	if (setjmp(env) != 2) {
		do_instruction();
	} 
	do_susb1_finish_int();
}

/*{{{asm sub_146(r0,r1) -> r0
  4146h and r1, r1
  4148h jz loc_4154h ; x:loc_4154h
  414ah shr r0, 1
  414ch and r0, 7fffh
  4150h subi r1, 1
  4152h jnz loc_414ah ; x:loc_414ah
  4154h ret
  asm}}}*/ 
uint16_t sub_4146(uint16_t v0, uint16_t v1) { //rshift
  for (int i = 0; i < v1; i ++)
    v0 = (v0 >> 1) & 0x7fff;

  return v0;
}

/*{{{asm sub_156(r0,r1) -> r0
  4156h and r1, r1
  4158h jz loc_4160h ; x:loc_4160h
  415ah shl r0, 1
  415ch subi r1, 1
  415eh jnz loc_415ah ; x:loc_415ah
  4160h ret
  asm}}}*/
uint16_t sub_4156(uint16_t v0, uint16_t v1) { //lshift
  for (int i = 0; i < v1; i ++)
    v0 <<= 1;

  return v0;
}

/*{{{asm sub_162(r0,r1,r2) -> r0 done
  4162h addi r1, 1
  4164h shl r1, 1

  4166h and r1, r1
  4168h jz sub_41a6h ; x:sub_41a6h ; saute si r1 == 0
  416ah cmp r1, 2
  416eh jz sub_41a6h ; x:sub_41a6h
  4170h mov word ptr [sp], r0   ; sauvegarde r0
  4172h and r0, 0fh
  4176h cmp r0, 0fh
  417ah mov r0, word ptr [sp]   ; restauration de r0
  417ch jnz sub_41a6h ; x:sub_41a6h
  417eh shr r1, 1
  4180h and r1, r1
  4182h jz loc_419eh ; x:loc_419eh
  4184h mov word ptr [sp], r0
  4186h call sub_41a6h ; x:sub_41a6h
  418ah mov word ptr [4072h], r0
  418eh mov r0, word ptr [sp]
  4190h addi r0, 1
  4192h call sub_41a6h ; x:sub_41a6h
  4196h shl r0, 8
  4198h and r0, byte ptr [4072h]
  419ch ret

  419eh call sub_41a6h ; x:sub_41a6h
  41a2h shr r2, 8
  41a4h addi r0, 1
  asm}}}*/

/* get a value at addr */
uint16_t sub_4162(uint16_t addr, uint16_t size) {
  return sub_4166(addr, (size + 1) << 1, UNUSED);
};

/* set or get a value at addr */
uint16_t sub_4166(uint16_t addr, uint16_t op, uint16_t value) {
   uint16_t ret = 0;

   if (op != DO_SET_BYTE && op != DO_GET_BYTE) {
	   if ((addr & 0xf) != 0xf)
		   return sub_41a6(addr, op, value);
   }

  switch(op) {
	  case DO_SET_BYTE: // set byte
		  sub_41a6(addr, DO_SET_BYTE, value);
		  break;
	  case DO_SET_WORD: // set word
		  sub_41a6(addr, DO_SET_WORD, value);
		  sub_41a6(addr + 1, 0, value >> 8);
		  break;
	  case DO_GET_BYTE: // get byte 
		  ret = sub_41a6(addr, DO_GET_BYTE, UNUSED);
		  break;
	  case DO_GET_WORD: // get word
		  sw(0x4072, sub_41a6(addr, DO_GET_WORD, UNUSED));
		  ret = sub_41a6(addr + 1, DO_GET_WORD, UNUSED);
		  ret = (ret << 8) & rb(0x4072); /* strange, should be | */
  }

  return ret;
}

/*{{{asm sub_41a6(v0, v1, v2) done
  41a6h int 49h
  41a8h call sub_41dah ; x:sub_41dah
  41ach mov word ptr [406eh], r0
  41b0h int 4ah
  41b2h mov word ptr [sp], r8
  41b4h mov r8, word ptr [406eh]
  41b8h cmp r1, 2                     ; c set si 2 > r1
  41bch jnc loc_41cah ; x:loc_41cah   ; saute si 2 <= r1
  41beh and r1, r1                    
  41c0h jz loc_41c6h ; x:loc_41c6h    ; saute si r1 == 0
  41c2h mov word ptr [r8], r2
  41c4h jmp loc_41d6h ; x:loc_41d6h
  41c6h mov byte ptr [r8], r2
  41c8h jmp loc_41d6h ; x:loc_41d6h
  41cah cmp r1, 4
  41ceh jnz loc_41d4h ; x:loc_41d4h ; saute si r1 != 4
  41d0h mov r0, word ptr [r8]
  41d2h jmp loc_41d6h ; x:loc_41d6h
  41d4h mov r0, byte ptr [r8]
  41d6h mov r8, word ptr [sp]
  41d8h ret
  asm}}}*/

uint16_t sub_41a6(uint16_t v0, uint16_t v1, uint16_t v2) {
  puint16_t ret;

  debug(DEBUG, "v0 = %x, v1 = %x, v2 = %x", v0, v1, v2);

  ret = sub_41da(v0, v1);

  debug(DEBUG, "NEW_OFF_SRC <- 0x%04x", ret);
  sw(NEW_OFF_SRC, ret);

  switch(v1) {
    case 0:
      debug(DEBUG, "b[NEW_OFF_SRC] <- 0x%x", v2 & 0xff);
      sb(ret, v2); break;
    case 1:
      debug(DEBUG, "w[NEW_OFF_SRC] <- 0x%x", v2);
      sw(ret, v2); break;
    case 4:
      debug(DEBUG, "return w[NEW_OFF_SRC] = 0x%x", rw(ret));
      return rw(ret);
    default:
      debug(DEBUG, "return b[NEW_OFF_SRC] = 0x%x", rb(ret));
      return rb(ret);
  }

  return v0;
}

/*{{{asm sub_1da(v0,v1) done
  41dah mov r5, r0      
  41dch and r5, 0fff0h               ; r5 = v0 & 0xfff0
  41e0h mov r6, r1                   ; r6 = v1
  41e2h mov r7, 5                    ; r7 = 5
  41e6h mov r8, 405eh                ; r8 = 0x405e
  41eah mov r9, 4054h                ; r9 = 0x4054
  41eeh mov r10, 4000h               ; r10 = buffer
  41f2h int 49h
  41f4h addi word ptr [r8++], 1          ; w[405e] += 1, r8 = 0x4060
  41f6h subi r7, 1                       ; r7--
  41f8h jnz loc_41f4h                    ; x:loc_41f4h, saute si r7 != 0
  41fah int 4ah                          ; r7 = 5, r8 = 0x405e

  ; init
  41fch mov r11, r8                      ; r11 = 0x405e
  41feh mov r1, word ptr [r8]            ; r1 = w[405e] (offsets[5])
  4200h mov r2, r9                       ; r2 = 0x4054
  4202h mov r3, r10                      ; r3 = 0x4000

  ; i = 0
  4204h mov r4, word ptr [r9]            ; r4 = w[4054 + 2 * i] (buf_054[i])
  4206h and r4, 1                        ; r4 = w[4054 + 2 * i] & 1
  420ah jz loc_4210h ; x:loc_4210h       ; saute si w[4054 + 2 * i] & 1 == 0
  ; sinon, w[4054 + 2 * i] & 1 !=0
  420ch mov r1, 0ffffh                   ; r1 = 0xffff
  ; loc_4210
  4210h mov r4, word ptr [r9++]          ; r4 = w[0x4054 + 2 * i] (buf_054[i]), r9 += 2 (i += 1)
  4212h and r4, 0fffeh                   ; r4 = r4 & 0xfffe
  4216h cmp r5, r4                       ; (v0 & 0xfff0) == (buf_054[i] & 0xfffe) ?
  4218h jnz loc_422eh ; x:loc_422eh      ; saute si (v0 & 0xfff0) != (buf_054[i] & 0xfffe)
  ; sinon, (v0 & 0xfff0) == (buf_054[i] & 0xfffe)
  421ah subi r9, 2                       ; r9 -= 2
  421ch and r6, 6                        ; r6 = v1 & 6
  4220h jnz loc_4226h ; x:loc_4226h      ; saute si v1 & 6 != 0
  ; sinon, v1 & 6 == 0
  4222h or word ptr [r9], 1              ; buf_054[i] |= 1
  ; loc_4226h
  4226h sub r0, r5                       ; r0 = v0 - (0xfff0 & v0)
  4228h add r0, r10                      ; r0 = buffer + v0 - (0xfff0 & v0)
  422ah xor word ptr [r8], word ptr [r8] ; buf_054[5+i] = 0
  422ch ret

  ; loc_422eh depuis 4218h, 
  422eh addi r8, 2                      ; r8 += 2
  4230h add r10, 10h
  4234h subi r7, 1
  4236h jz end_loop ; x:loc_4246h       ; saute si r7 == 0
  4238h cmp word ptr [r8], r1           ; src = r1, dst = w[r8], cmp <=> w[r8] - r1 (c set si r1 > w[r8] )
  423ah jc loc_4244h ; x:loc_4244h      ; saute si r1 > w[8] (w[8] et r1 ne sont pas signés)

  423ch mov r1, word ptr [r8]
  423eh mov r11, r8
  4240h mov r2, r9
  4242h mov r3, r10

  4244h jmp start_loop ; x:loc_4204h

  4246h xor word ptr [r11], word ptr [r11]
  4248h mov r10, 4068h
  424ch mov word ptr [r10++], r3   ; w[BUF_ADDR] = r3
  424eh mov word ptr [r10++], r2   ; w[OFF_ADDR] = r2
  4250h addi r10, 2                
  4252h mov word ptr [r10++], r0   ; w[NEW_OFF_DEST] = r0
  4254h mov r10, 411ah
  4258h mov r11, 4120h
  425ch mov word ptr [r10++], word ptr [r11++] ; w[0x411a] = w[SAVED_OFF_ADDR]
  425eh mov word ptr [r10++], word ptr [r11++] ; w[CURRENT_BYTE] = w[SAVED_OFF_SRC]
  4260h mov word ptr [r10++], word ptr [r11++] ; w[0x411d] = w[SAVED_OFF_DEST]
  4262h mov sp, word ptr [4070h]               ; sp pointe sur 40fah
  4266h ret                                    ; retour sur 40fah
asm}}}*/

/* cette fonction implémente des fonctionnalités de translation d'adresses et de cache
 * entre la mémoire du client (ssticrypt) et la webcam */
puint16_t sub_41da(uint16_t v0, uint16_t v1) {
  uint16_t r1 = 0, r11, new_off_addr, new_buf_addr, tmp_buf_addr;
  int i;

  debug(DEBUG, "v0 = %x, v1 = %x", v0, v1);

  // 41f4h -> 41f8h
  for (i = 0; i < 5; i++) {
    incw(cnta(5 + i));
  }

  // 41fch -> 4202h
  tmp_buf_addr = 0x4000;

  r11 = 0x405e;
  r1 = rw(r11);
  new_off_addr = 0x4054;
  new_buf_addr = 0x4000;

  for (i = 0; i < 5; i++) {
    if (r1 <= rw(cnta(5 + i))) {
      r11 = cnta(5 + i);
      r1 = rw(r11);
      new_off_addr = cnta(i);
      new_buf_addr = tmp_buf_addr;
    }

    // 4204h -> 420ch
    if ( (rw(cnta(i)) & 1) != 0 )
      r1 = 0xffff;

    debug(DEBUG, "i = %d, r1 = %x, cnta(i) = %x, cnta(5 + i) = %x", 
        i, r1, rw(cnta(i)), rw(cnta(5 + i)));

    if ( (v0 & 0xfff0) == (rw(cnta(i)) & 0xfffe) ) {
      if ((v1 & 6) == 0) {
        orw(cnta(i), 1);
      }

      sw(cnta(5 + i), 0);
      return tmp_buf_addr + ( v0 - (0xfff0 & v0) );
    }

    // loc_422eh
    tmp_buf_addr += 16;
  }

  sw(r11, 0);
  sw(BUF_ADDR, new_buf_addr);
  sw(OFF_ADDR, new_off_addr);
  sw(NEW_OFF_SRC, v0);

  sw(0x411a, rw(SAVED_OFF_ADDR));
  /* on restaure le program counter sauvegardé à l'entrée de do_instruction */
  sw(CURRENT_BYTE, rw(SAVED_OFF_DEST));
  sw(CURRENT_BITS, rw(SAVED_OFF_SRC));

  debug(CRIT, "needs more bytes, exiting...");
  longjmp(env, 2);
}

/*{{{asm sub_268(v0, v1, v2)
  4268h int 49h                        ; sauvegarde des registres
  426ah mov word ptr [sp], r0          ; sauvegarde de r0 (v0)
  426ch mov r10, r0                    ; r10 = v0
  426eh xor r11, r11                   ; r11 = 0
  4270h mov r14, 1                     ; r14 = 1
  4274h mov r13, 8                     ; r13 = 8
  4278h mov r5, r13                    ; r5 = r13 = 8
  427ah sub r5, word ptr [411eh]       ; r5 -= w11e
  427eh cmp r10, r5                    ; v0 - r5 
  4280h ja loc_42c8h ; x:loc_42c8h     ; saute si z = 0 et c = 0 <=> r10 > r5 <=> v0 > 8 - w11e
  ; sinon, v0 <= 8 - w11e
  4282h mov r1, r11                    ; r1 = r11 = 0
  4284h mov r0, word ptr [411ch]       ; r0 = w11c
  4288h call sub_4162h ; x:sub_4162h   ; r0 = sub_4162(w11c, r11, v2)
  428ch mov r1, r5                     
  428eh sub r1, r10                    ; r1 = r5 - r10
  4290h call rshift ; x:sub_4146h      ; r0 = r0 >> (r5 - r10)
  4294h mov r13, r0                    ; r13 = r0
  4296h mov r1, r10                    ; r1 = r10
  4298h mov r0, 0ffffh                 ; r0 = 0xffff
  429ch call lshift ; x:sub_4156h      ; r0 = 0xffff << r10
  42a0h not r0                 
  42a2h and r0, r13                    ; r0 = ~r0 & r13 = ~(0xffff << r10) & (r0 >> (r5 - r10))
  ;    = ~(0xffff << r10) & (sub_4162(w11c, r11, v2) >> (r5 - r10))
  ;    = ~(0xffff << v0) & (sub_4162(w11c, 0, v2) >> (8 - w11e - v0))

  42a4h mov r10, word ptr [sp]         ; r10 = v0
  42a6h mov r4, word ptr [411eh]       ; r4 = word_411e
  42aah add r4, r10                    ; r4 = word_411e + v0
  42ach mov r5, r4                     ; r5 = word_411e + v0
  42aeh shr r5, 3                      ; r5 = (word_411e + v0) >> 3
  42b0h and r5, 1fffh                  ; r5 = ( (word_411e + v0) >> 3 ) & 0x1fff
  42b4h add word ptr [411ch], r5       ; word_411c += ( (word_411e + v0) >> 3 ) & 0x1fff
  42b8h and r4, 7                      ; r4 = ( word_411e + v0 ) & 7
  42bch mov word ptr [411eh], r4       ; word_411e = ( word_411e + v0 ) & 7
  42c0h mov word ptr [sp + 1ch], r0    
  42c4h int 4ah
  42c6h ret                            ; return r0

  42c8h mov r1, r11                    ; r1 = 0
  42cah mov r0, word ptr [411ch]       ; r0 = w11c
  42ceh call sub_4162h ; x:sub_4162h   
  42d2h mov r12, r0                    ; r12 = sub_4162h(w11c, 0, v2)
  42d4h sub r13, word ptr [411eh]      ; r13 = 8 - w11e
  42d8h mov r1, r13                    ; 
  42dah mov r0, 0ffffh                 ;
  42deh call lshift ; x:sub_4156h      ; r0 = 0xffff << (8 - w11e)
  42e2h not r0                         ; r0 = ~( 0xffff << (8 - w11e) )
  42e4h and r12, r0                    ; r12 = sub_4162h(w11c, 0, v2) & ~( 0xffff << (8 - w11e) )
  42e6h sub r10, r13                   ; r10 = v0 - (8 - w11e)

  42e8h cmp r10, 7                     
  42ech jbe loc_4310h ; x:loc_4310h    ; saute si v0 - (8 - w11e) <= 7
  ; sinon v0 - (8 - word_411e) > 7
  42eeh shl r12, 8                     ; r12 = r12 << 8 = sub_4162h(w11c, 0, v2) << 8
  42f0h mov r5, word ptr [411ch]       ; r5 = word_411c
  42f4h add r5, r14                    ; r5 = word_411c + r14
  42f6h xor r1, r1                     ; r1 = 0
  42f8h stX
  42fah jc loc_4310h ; x:loc_4310h     ; saute si carry <=> word_411c + r14 > 0xffff
  42fch mov r0, r5
  42feh call sub_4162h ; x:sub_4162h   ; r0 = sub_4162h(word_411c + r14, 0, v2)
  4302h or r12, r0                     ; r12 = (sub_4162h(w11c, 0, v2) << 8) | sub_4162h(word_411c + 1, 0, v2)
  4304h addi r14, 1                    ; r14 += 1
  4306h add r10, 0fff8h                ; r10 += 0fff8h
  430ah xor r0, r0                     ; r0 = 0
  430ch stX                            ; 
  430eh jnc loc_42e8h ; x:loc_42e8h    ; saute si pas carry <=> r10 + 0xfff8 <= 0xffff

  4310h mov r1, r10                    ;
4312h mov r0, r12
4314h call lshift ; x:sub_4156h
4318h mov r12, r0                    ; r12 = r12 << r10
431ah mov r0, word ptr [411ch]       ; r0 = word_411c
431eh add r0, r14                    ; r0 = word_411c + r14
4320h xor r1, r1                     ; 
4322h call sub_4162h ; x:sub_4162h   ; r0 = sub_4162h(word_411c + r14, 0, v2)
4326h mov r1, 8                      ; 
432ah sub r1, r10                    ; r1 = 8 - r10
432ch call rshift ; x:sub_4146h      ; r0 = sub_4162h(word_411c + r14, 0, v2) >> (8 - r10)
4330h mov r13, r0                    ; 
4332h mov r1, r10                    ; 
4334h mov r0, 0ffffh                 ;
4338h call lshift ; x:sub_4156h      ; r0 = 0xffff << r10
433ch not r0                         ; r0 = ~(0xffff << r10)
433eh and r0, r13                    ; r0 = ~(0xffff << r10) & sub_4162h(word_411c + r14, 0, v2) << (8 - r10)
4340h or r0, r12                     ; r0 = ~(0xffff << r10) & sub_4162h(word_411c + r14, 0, v2) << (8 - r10) | r12
4342h jmp exit_func ; x:loc_42a4h
asm}}}*/

uint16_t read_nbits(uint16_t needed) {
  uint16_t ret, remaining, ncur_byte, tmp;
  uint16_t pos;

  debug(DEBUG, "needed = %x, CURRENT_BYTE = 0x%04x, CURRENT_BITS = 0x%04x",
      needed, rw(CURRENT_BYTE), rw(CURRENT_BITS));

  /* remain est le nombre de bits qu'il reste à traiter dans l'octet courant */
  remaining = 8 - rw(CURRENT_BITS);

  pos = rw(CURRENT_BITS) + needed;
  ncur_byte = rw(CURRENT_BYTE);

  ret = GET_BYTE(ncur_byte);

  if (needed <= remaining) {
    /* on demande moins de bits que dispo */
    ret = KEEP_NBITS(ret >> (remaining - needed), needed);
  } else {
    /* sinon il va falloir aller chercher dans le ou les octets suivants */
    ret = KEEP_NBITS(ret, remaining);
    needed -= remaining;
    ncur_byte++;

    if (needed >= 8) {
      ret = (ret << 8) | GET_BYTE(ncur_byte++);
      needed -= 8;
    }

    // 4318h
    tmp = GET_BYTE(ncur_byte) >> (8 - needed);
    ret = KEEP_NBITS(tmp, needed) | (ret << needed);
  }

  /* mise à jour des compteurs */
  addw(CURRENT_BYTE, ( pos >> 3 ) & 0x1fff);
  sw(CURRENT_BITS, pos & 7);

  debug(DEBUG, "ret = %x, CURRENT_BYTE = 0x%04x, CURRENT_BITS = 0x%04x",
      ret, rw(CURRENT_BYTE), rw(CURRENT_BITS));
  return ret;
}

/*{{{asm sub_346: copie 6 mots de 0x126 vers 0x134
  4346h int 49h
  4348h mov r11, 4126h
  434ch mov r10, 4134h
  4350h mov r0, 6
  4354h mov word ptr [r10++], word ptr [r11++]
  4356h subi r0, 1
  4358h jnz loc_4354h ; x:loc_4354h
  435ah int 4ah
  435ch ret
  asm}}}*/

void set_dest_operand(void) {
  sw(DST_VALUE,     rw(SRC_VALUE));
  sw(DST_REG,       rw(SRC_REG));
  sw(DST_MEM_ADDR,  rw(SRC_MEM_ADDR));
  sw(DST_OBF_VALUE, rw(SRC_OBF_VALUE));
  sw(DST_SIZE,      rw(SRC_SIZE));
  sw(DST_TYPE,      rw(SRC_TYPE));
}

/*{{{asm sub_35e
  435eh mov r5, word ptr [413eh]
  4362h cmp r5, 2
  4366h jz loc_43b2h ; x:loc_43b2h
  4368h cmp r5, 3
  436ch jz loc_4392h ; x:loc_4392h
  436eh and r5, r5
  4370h jz loc_4374h ; x:loc_4374h

  4372h ret ; exit

  4374h mov r9, word ptr [4136h]
  4378h shl r9, 1
  437ah cmp word ptr [413ch], 0
  4380h jz loc_438ah ; x:loc_438ah
  4382h mov word ptr [r9 + 40feh], word ptr [4126h]
  4388h jmp exit ; x:loc_4372h

  438ah mov byte ptr [r9 + 40feh], byte ptr [4126h]
  4390h jmp exit ; x:loc_4372h

  4392h mov r3, byte ptr [413ch]
  4396h mov r9, word ptr [4136h]
  439ah shl r9, 1
  439ch mov r4, word ptr [4126h]
  43a0h mov r2, word ptr [413ah]
  43a4h mov r1, word ptr [r9 + 40feh]
  43a8h mov r0, word ptr [4138h]
  43ach call sub_484ch ; x:sub_484ch
  43b0h jmp exit ; x:loc_4372h

  43b2h mov r1, byte ptr [413ch]
  43b6h mov r2, word ptr [4126h]
  43bah mov r0, word ptr [4138h]
  43beh call sub_4166h ; x:sub_4166h
  43c2h jmp exit ; x:loc_4372h
  asm}}}*/

void save_dest(void) {
	uint16_t reg;

	reg = REG_BASE + 2 * rw(DST_REG);

	switch(rw(DST_TYPE)) {
		case 0:
			// loc_4374h
			if (rw(DST_SIZE) == 0) {
				sb(reg, rb(SRC_VALUE));
			} else {
				sw(reg, rw(SRC_VALUE));
			}
			break;
		case 2:
			// loc_43b2h
			sub_4166(rw(DST_MEM_ADDR), rb(DST_SIZE), rw(SRC_VALUE));
			break;
		case 3:
			// loc_4392h
			sub_484c(rw(DST_MEM_ADDR), rw(reg), rw(DST_OBF_VALUE),
					rw(DST_SIZE), rw(SRC_VALUE));
			break;
	}
}

/*{{{asm sub_3c4(v0, v1, v2)
  43c4h mov r0, 1
  43c8h call read_nbitsh ; x:read_nbitsh  ; r0 = read_nbitsh(1, v1, v2)
  43cch mov word ptr [412eh], r0      ; word_412eh = read_nbitsh(1, v1, v2);
  43d0h mov r0, 2                     ;
  43d4h call read_nbitsh ; x:read_nbitsh  ; r0 = read_nbitsh(2, v1, v2)
  43d8h mov word ptr [4130h], r0      ; word_4130h = read_nbitsh(2, v1, v2)
  43dch cmp r0, 1                     ;
  43e0h jz loc_44c2h ; x:loc_44c2h    ; saute si r0 == 1
  ; sinon, r0 != 1
  43e4h jc loc_44a8h ; x:loc_44a8h    ; saute si carry <=> r0 < 1 <=> r0 == 0
  ; sinon, r0 > 1
  43e8h cmp r0, 2                     ;
  43ech jz loc_4430h ; x:loc_4430h    ; saute si r0 == 2
  ; sinon, r0 > 2
  43eeh mov r0, 10h                   ;
  43f2h call read_nbitsh ; x:read_nbitsh  ; r0 = read_nbitsh(16, v1, v2)
  43f6h mov word ptr [412ah], r0      ; word_412ah = read_nbitsh(16, v1, v2)
  43fah mov r0, 4                     ;
  43feh call read_nbitsh ; x:read_nbitsh  ; 
  4402h mov word ptr [4128h], r0      ; word_4128h = read_nbitsh(4, v1, v2)
  4406h mov r0, 6                     ; 
  440ah call read_nbitsh ; x:read_nbitsh  ; r0 = read_nbitsh(6, v1, v2)
  440eh mov r2, r0                    ; r2 = read_nbitsh(6, v1, v2)
  4410h mov word ptr [412ch], r0      ; word_412ch = read_nbitsh(6, v1, v2)
  4414h mov r3, byte ptr [412eh]      ; r3 = word_412eh = read_nbitsh(1, v1, v2)
  4418h mov r9, word ptr [4128h]      ; r9 = word_4128h = read_nbitsh(4, v1, v2)
  441ch shl r9, 1                     ; r9 = r9 << 1 = 2 * r9
  441eh mov r1, word ptr [r9 + 40feh] ; r1 = buf_40fe[word_4128h]
  4422h mov r0, word ptr [412ah]      ; r0 = word_412ah
  4426h call sub_4848h ; x:sub_4848h  ; r0 = sub_4848h(word_412ah, buf_40fe[word_4128h], read_nbitsh(6, v1, v2), read_nbitsh(1, v1, v2))
  ; word_4126h = sub_4848h(word_412ah, buf_40fe[word_4128h], read_nbitsh(6, v1, v2), read_nbitsh(1, v1, v2))
  ; return sub_4848h(word_412ah, buf_40fe[word_4128h], read_nbitsh(6, v1, v2), read_nbitsh(1, v1, v2))

  442ah mov word ptr [4126h], r0      ; word_4126h = r0
  ; return r0
  442eh ret

  ; r0 == 2 <=> read_nbitsh(2, v1, v2) == 2
  4430h call read_nbitsh ; x:read_nbitsh   ; r0 = read_nbitsh(2, v1, v2)
  4434h mov word ptr [4132h], r0       ; word_4132h = read_nbitsh(2, v1, v2)
  4438h cmp r0, 1                      ;
  443ch jz loc_449ah ; x:loc_449ah     ; saute si r0 == 1
  ; sinon, r0 != 1
  443eh jc loc_4482h ; x:loc_4482h     ; saute si r0 < 1 <=> r0 == 0
  ; sinon, r0 > 1
  4440h cmp r0, 2                     
  4444h jz loc_4454h ; x:loc_4454h     ; saute si r0 == 2
  ; sinon, r0 > 2

  4446h mov r1, byte ptr [412eh]       ; r1 = word_412eh = read_nbitsh(1, v1, v2)
  444ah mov r0, word ptr [412ah]       ; r0 = word_412ah
  444eh call sub_4162h ; x:sub_4162h   ; r0 = sub_4162h(word_412ah, word_412eh, v2)
  4452h jmp loc_exit ; x:loc_442ah     ; word_4126h = sub_4162h(word_412ah, word_412eh, v2)
  ; return sub_4162h(word_412ah, word_412eh, v2)

  ; saut depuis 4444h, r0 == 2
  4454h mov r0, 10h                         
  4458h call read_nbitsh ; x:read_nbitsh                 ; r0 = read_nbits(16, v1, v2)
  445ch mov word ptr [412ah], r0                     ; word_412ah = read_nbits(16, v1, v2)
  4460h mov r0, 4                                    ; 
  4464h call read_nbitsh ; x:read_nbitsh                 ; r0 = read_nbitsh(4, v1, v2)
  4468h xor r1, r1                                   ; r1 = 0
  446ah subi r1, 1                                   ; r1 = 0xffff 
  446ch mov r9, r0                                   ; r9 = read_nbitsh(4, v1, v2)
  446eh mov word ptr [4128h], r0                     ; word_4128h = read_nbitsh(4, v1, v2)
  4472h add r9, r0                                   ; r9 = 2 * read_nbitsh(4, v1, v2)
  4474h add word ptr [412ah], word ptr [r9 + 40feh]  ; word_412ah += buf_40fe[word_4128h]
  447ah add r1, 13h                                  ; r1 = 0xffff + 0x13 = 0x12 => z = 0, c = 1, o = 0, s = 0
  447eh clX                                          ; clear c ?
  4480h jbe save_exit ; x:loc_4446h                  ; saute si z == 1 ou c == 1
; sinon, z == 0 et c == 0
4482h mov r0, 4                                
4486h call read_nbitsh ; x:read_nbitsh                 ; r0 = read_nbitsh(4, v1, v2)
448ah mov r9, r0                                   ; 
448ch mov word ptr [4128h], r0                     ; word_4128h = read_nbitsh(4, v1, v2)
4490h add r9, r0                                   ; r9 = 2 * read_nbitsh(4, v1, v2)
4492h mov word ptr [412ah], word ptr [r9 + 40feh]  ; word_412ah = buf_40fe[word_4128h]
4498h jmp save_exit ; x:loc_4446h

; saut depuis 443ch, r0 == 1
449ah mov r0, 10h                       ; 
449eh call read_nbitsh ; x:read_nbitsh      ; 
44a2h mov word ptr [412ah], r0          ; word_412ah = read_nbits(16, v1, v2)
44a6h jmp save_exit ; x:loc_4446h        

; saut depuis 43e4h, word_4130h == 0
44a8h mov r0, 4                         
44ach call read_nbitsh ; x:read_nbitsh                ; r0 = read_nbits(0, v1, v2)
44b0h mov r9, r0                         
44b2h mov word ptr [4128h], r0                    ; word_4128h = read_nbits(0, v1, v2)
44b6h add r9, r0
44b8h mov word ptr [4126h], word ptr [r9 + 40feh] ; word_4126h = buf_40fe[word_4128h]
44beh jmp loc_442eh ; x:loc_442eh                 ; return buf_40fe[word_4128h]

; saut depuis 43e0h, word_4130h == 1
44c2h mov r0, 10h                                 ; r0 = 16
44c6h cmp word ptr [412eh], 0                     ; 
44cch jnz loc_44d2h ; x:loc_44d2h                 ; saute si word_412eh != 0
; sinon, word_412eh == 0
44ceh mov r0, 8

44d2h call read_nbitsh ; x:read_nbitsh               
44d6h jmp set_4126h_exit ; x:loc_442ah           ; word_4126h = read_nbitsh(r0, v1, v2)
; return read_nbitsh(r0, v1, v2)
asm}}}*/

void decode_operands(void) {
  uint16_t ret, r0;
  uint16_t size, type, reg;

  size = read_nbits(1);
  sw(SRC_SIZE, size);
  type = read_nbits(2);
  sw(SRC_TYPE, type);

  //debug(CRIT, "SRC_TYPE = %s, SRC_SIZE = %d", op_types[type], size);

  switch(type) {
    case OP_TYPE_REG: // loc_44a8h
      reg = read_nbits(4);
      sw(SRC_REG, reg);
      sw(SRC_VALUE, READ_REG(reg));
      debug(WARN, "REG r%d = 0x%x", reg, READ_REG(reg));
      ret = reg;
      break;
    case OP_TYPE_IMMEDIATE: // loc_44c2h
      ret = read_nbits( (rw(SRC_SIZE) == 0) ? 8 : 16);
      debug(WARN, "IMM 0x%x", ret);
      sw(SRC_VALUE, ret);
      break;
    case OP_TYPE_MEMREF: // loc_4430h
      r0 = read_nbits(2);
      sw(OP_MEMREF_TYPE, r0);
      //debug(DEBUG, "OP_MEMREF_TYPE = %d", r0);
      switch(r0) {
        case 0: // loc_4482h
          reg = read_nbits(4);
          sw(SRC_REG, reg);
          sw(SRC_MEM_ADDR, READ_REG(reg));
          debug(WARN, "MEMREF REG r%d = 0x%x", reg, READ_REG(reg));
          break;
        case 1: // loc_449ah
          r0 = read_nbits(16);
          sw(SRC_MEM_ADDR, r0);
          debug(WARN, "MEMREF IMM 0x%x", r0);
          break;
        case 2: // loc_4454h
          r0 = read_nbits(16);
          sw(SRC_MEM_ADDR, r0);
          reg = read_nbits(4);
          sw(SRC_REG, reg);
          addw(SRC_MEM_ADDR, READ_REG(reg)); // si clc fait rien
          // sw(OP_MEM_ADDR, rw(0x40fe + 2 * r0); clX <=> clc, équivalent case 0
          debug(WARN, "MEMREF IMM OFFSET 0x%x + (r%d = 0x%x)", r0, reg, READ_REG(reg));
          break;
      }
      ret = sub_4162(rw(SRC_MEM_ADDR), rw(SRC_SIZE));
      //debug(WARN, "w[%x] = 0x%x", rw(SRC_MEM_ADDR), ret);
      sw(SRC_VALUE, ret);
      break;
    case 3: // 43eeh
      r0 = read_nbits(16);
      sw(SRC_MEM_ADDR, r0);
      reg = read_nbits(4);
      sw(SRC_REG, reg);
      r0 = read_nbits(6);
      sw(SRC_OBF_VALUE, r0);
      debug(CRIT, "OBF OP: SRC_MEM_ADDR = %x, r%d = %x, v = %x",
          rw(SRC_MEM_ADDR), reg, READ_REG(reg), rw(SRC_OBF_VALUE));
      ret = sub_4848(rw(SRC_MEM_ADDR), READ_REG(reg), rw(SRC_OBF_VALUE), rw(SRC_SIZE));
      sw(SRC_VALUE, ret);
  }
}
/*{{{asm sub_4da(v2)
  44dah mov word ptr [4070h], sp                   ; setjmp(env);
  44deh mov r11, 411ah                             ; 
  44e2h mov r10, 4120h                             ; 
  44e6h mov word ptr [r10++], word ptr [r11++]     ; word_4120h = word_411ah
  44e8h mov word ptr [r10++], word ptr [r11++]     ; w122 = w11c
  44eah mov word ptr [r10++], word ptr [r11++]     ; w124 = w11e
  44ech mov r0, 1
  44f0h call read_nbitsh ; x:read_nbitsh               ; r0 = sub268(1, v2);
  44f4h mov r14, r0                                
  44f6h and r14, 1                                 ; r14 = sub268(1, v2) & 1;
  44fah mov r0, 8
  44feh call read_nbitsh ; x:read_nbitsh               ; r0 = sub268(8, v2)
  4502h cmp r0, 0ffh                               
  4506h jz exit_sub44da ; x:exit_sub44da           ; saute si sub268(8, v2) == 0xff
  ; sinon, sub268(8, v2) != 0xff
  450ah mov r11, r0                                ; r11 = sub268(8, v2)
  450ch mov r12, word ptr [4144h]                  ; r12 = word_4144h
  4510h and r14, r14                               ;
  4512h jnz loc_4518h ; x:loc_4518h                ; saute si r14 != 0 <=> sub268(1, v2) & 1 != 0
  ; sinon,  sub268(1, v2) & 1 == 0
  4514h shr r11, 4                                 ; r11 = sub268(8, v2) >> 4
  4516h shr r12, 4                                 ; r12 = word_4144h >> 4

  4518h and r11, 0fh                               ; r11 &= 0x0f
  451ch add r11, 0c0h                              ; r11 += 0xc0 (r11 est compris entre 0xc0 et 0xcf)
  4520h and r12, 0fh                               ; r12 &= 0x0f
  4524h mov byte ptr [4537h], r11                  ; word_4536 = 01c3 => 01c0, 01cf 
  4528h mov r0, word ptr [0c000h]                  ; charge les flags (memory mapped) dans r0
  452ch and r0, 0fff0h                             ; ne garde que le flag I dans r0 (clear les flags de condition)
  4530h or r0, r12                                 ; r0 |= r12,
  4532h mov word ptr [0c000h], r0                  ; restaure les flags
  4536h jnc loc_453ah ; x:loc_453ah                ; saute si r12 == r11
  ; sinon, si r12 != r11
  4538h addi r14, 2                                ; r14 += 2 (r14 compris entre 2 et 3)

  ; loc_453ah
  453ah xor r11, r11                               ; r11 = 0
  453ch mov r0, 3
  4540h call read_nbitsh ; x:read_nbitsh               ; r0 = sub268(3, v2)
  4544h mov r13, r0                                ; r13 = sub268(3, v2)
  4546h mov r0, 1
  454ah call read_nbitsh ; x:read_nbitsh               ; r0 = sub268(1, v2)
  454eh mov r6, r0                                 ; r6 = sub268(1, v2)
  4550h mov word ptr [4126h], r11                  ; w[126] = 0
  4554h cmp r13, 2                                 ; sub268(3, v2) <=> 2
  4558h jz loc_45beh ; x:loc_45beh                 ; saute si sub268(3, v2) == 2
  ; sinon, sub268(3, v2) != 2
  455ah jc loc_4574h ; x:loc_4574h                 ; saute si sub268(3, v2) < 2
  ; sinon, sub268(3, v2) > 2
  455ch cmp r13, 4
  4560h jz loc_460ah ; x:loc_460ah                 ; saute si sub268(3, v2) == 4
  ; sinon, sub268(3, v2) != 4
  4564h jc loc_45d0h ; x:loc_45d0h                 ; saute si sub268(3, v2) < 4
  ; sinon, sub268(3, v2) > 4
  4566h cmp r13, 7
  456ah ja start_func ; x:sub_44dah                ; saute si sub268(3, v2) > 7 (saute au début de la fonction)
  ; sinon, sub268(3, v2) <= 7 (5 < sub268(3, v2) <= 7)
  456eh stc                            
  4570h jc loc_4702h ; x:loc_4702h                 ; saute dans tous les cas ?

  ; loc_4574h, sub268(3, v2) < 2, r6 = sub268(1, v2)
  4574h call decode_operandsh ; x:decode_operandsh               ; sub3c4(v2, v4, v6)
  4578h call set_dest_operandh ; x:set_dest_operandh               ; sub346()
  457ch call decode_operandsh ; x:decode_operandsh               ; sub3c4(v2, v4, v6)
  4580h mov r0, word ptr [4134h]                   ; r0 = word_4134
  4584h cmp r13, r11                              
  4586h jz loc_458eh ; x:loc_458eh                 ; saute si r13 == r11 <=> sub268(3, v2) == 0
  ; sinon, sub268(3, v2) == 1
  4588h or r0, word ptr [4126h]                    ; r0 = word_4134 | word_4126
  458ch jmp loc_4592h ; x:loc_4592h                ; saute

; loc_458eh                                      ; sub268(3, v2) == 0
458eh and r0, word ptr [4126h]                   ; r0 = word_4134 & word_4126
; loc_4592h
4592h mov r11, 4144h                             ; r11 = FLAGS
4596h mov r12, word ptr [r11]                    ; r12 = word_4144
4598h call sub_4814h ; x:sub_4814h               ; sub814(r6, r14)
459ch and r12, 0ffeeh                            ; r12 = word_4144 & 0xffee
45a0h mov r2, word ptr [r11]                     ; r2 = word_4144
45a2h and r2, 0ff11h                             ; r2 = word_4144 & 0xff11
45a6h or r2, r12                                 ; r2 = (word_4144 & 0xff11) | (word_4144 & 0xffee)
45a8h mov word ptr [r11], r2                     ; word_4144 = (word_4144 & 0xff11) | (word_4144 & 0xffee)

; loc_45aa
45aah mov word ptr [4126h], r0                   ; word_4126h = r0

45aeh mov r12, r14                               ; r12 = r14
45b0h and r12, 2                                 ; r12 = r14 & 2
45b4h jnz loc_45bah ; x:loc_45bah                ; saute si r14 & 2 != 0 (r14 égal à 1 ou 3)
; sinon, r14 & 2 = 0 (r14 égal à 0 ou 2)
45b6h call save_desth ; x:save_desth               ; r0 = sub35e(r6)
; loc_45bah
45bah jmp start_func ; x:sub_44dah               ; saute à sub_44dah

; loc_45beh, sub268(3, v2) == 2
45beh call decode_operandsh ; x:decode_operandsh               ; sub3c4(v2, v4, r6)
45c2h call set_dest_operandh ; x:set_dest_operandh               ; sub346()
45c6h not word ptr [4126h]                       ; w[126] = ~w[126]
45cah call sub_4814h ; x:sub_4814h               ; sub814(r6, r14)
45ceh jmp loc_45aeh ; x:loc_45aeh                ; saute

; loc_45d0h, sub268(3, v2) < 4
45d0h mov r0, 1
45d4h call read_nbitsh ; x:read_nbitsh               ; r0 = sub268(1, v2)
45d8h mov r10, r0                                ; r10 = sub268(1, v2)
45dah mov r0, 8                                  
45deh call read_nbitsh ; x:read_nbitsh               ; r0 = sub268(8, v2)
45e2h mov r12, r0                                ; r12 = sub268(8, v2)
45e4h call decode_operandsh ; x:decode_operandsh               ; sub3c4(v2, v4, r6)
45e8h call set_dest_operandh ; x:set_dest_operandh               ; sub346()
45ech mov r1, r12                                ; r1 = r12
45eeh mov r0, word ptr [4126h]                   ; r0 = word_4126
45f2h cmp r10, r11                               
45f4h jz loc_4600h ; x:loc_4600h                 ; saute si r10 == r11 <=> r10 == 0
; sinon, r10 != 0
45f6h call rshift ; x:sub_4146h                  ; r0 = word_4126 >> r12
45fah call sub_4814h ; x:sub_4814h               ; sub814(r6, r14)
45feh jmp loc_45aah ; x:loc_45aah                ; saute

; loc_4600
4600h call lshift ; x:sub_4156h                  ; r0 = word_4126 << r12
4604h call sub_4814h ; x:sub_4814h               ; sub814(r6, r14)
4608h jmp loc_45aah ; x:loc_45aah                ; saute

; loc_460ah, sub268(3, v2) == 4
460ah call decode_operandsh ; x:decode_operandsh               ; sub3c4(v2, v4, r6)
460eh mov r4, byte ptr [4130h]                   ; r4 = word_4130
4612h mov r3, word ptr [4128h]                   ; r3 = word_4128
4616h cmp r4, r11                                ;
4618h jnz loc_4622h ; x:loc_4622h                ; saute si word_4130 != r11
; sinon, word_4130 == r11
461ah cmp r3, 0fh                                
461eh jnz loc_4622h ; x:loc_4622h                ; saute si word_4128 != 0xf
; sinon, word_4128 == 0xf
4620h addi r11, 1                                ; r11 += 1

; loc_4622
4622h cmp r3, 0eh                                
4626h jnz loc_464ch ; x:loc_464ch                ; saute si word_4128 != 0xe
; sinon, word_4128 == 0xe
4628h cmp r4, 3                                  
462ch jz loc_463ch ; x:loc_463ch                 ; saute si word_4130 == 3
; sinon, word_4130 != 3
462eh cmp r4, 2                                 
4632h jnz loc_464ch ; x:loc_464ch                ; saute si word_4130 != 2
; sinon, word_4130 == 2
4634h cmp word ptr [4132h], 0                    
463ah jnz loc_464ch ; x:loc_464ch                ; saute si word_4132h != 0
; sinon, word_4132h == 0

; loc_463ch
463ch mov r12, r14                               ; 
463eh and r12, 2                                 ; r12 = r14 & 2
4642h jnz loc_464ch ; x:loc_464ch                ; saute si r14 & 2 != 0 (r14 égal à 1 ou 3)
; sinon, r14 & 2 == 0 (r14 égal à 0 ou 2)
4644h subi word ptr [411ah], 2                   ; word_411a -= 2
4648h subi word ptr [412ah], 2                   ; word_412a -= 2

; loc_464ch
464ch call set_dest_operandh ; x:set_dest_operandh               ; sub346()
4650h call decode_operandsh ; x:decode_operandsh               ; sub3c4(v2, v4, r6)
4654h mov r12, r14                               ; 
4656h and r12, 2                                 ; r12 = r14 & 2
465ah jnz start_func ; x:sub_44dah               ; saute si r14 & 2 != 0 (r14 égal à 1 ou 3)
; sinon, r14 & 2 == 0 (r14 égal à 0 ou 2)
465eh cmp word ptr [4128h], 0eh                  
4664h jnz loc_45aeh ; x:loc_45aeh                ; saute si word_4128 != 0xe
; sinon, word_4128 = 0xe
4668h mov r5, word ptr [4130h]                   ; r5 = word_4130
466ch cmp r5, 2                      
4670h jnz loc_46b4h ; x:loc_46b4h                ; saute si word_4130 != 2
; sinon, word_4130 == 2
4672h cmp word ptr [4132h], 0        
4678h jnz loc_45aeh ; x:loc_45aeh                ; saute si word_4132 != 0
; sinon, word_4132 == 0
467ch and r11, r11                               ;
467eh jz loc_46a6h ; x:loc_46a6h                 ; saute si r11 == 0
; sinon, r11 != 0
4680h mov r10, 412eh                             ; r10 = OP_SIZE
4684h mov r1, byte ptr [r10]                     ; r1 = b[412e]
4686h mov r12, 411ah                             ; 
468ah mov r0, word ptr [r12]                     ; r0 = w[411a]
468ch call sub_4162h ; x:sub_4162h
4690h mov word ptr [411eh], r0                   ; w[411e] = sub162(w[411a], b[412e], r2)
4694h mov r0, word ptr [r12]                     ; r0 = w[411a]
4696h addi r0, 2                                 ; r0 = w[411a] + 2
4698h mov r1, byte ptr [r10]                     ; r1 = b[412e]
469ah call sub_4162h ; x:sub_4162h               ; r0 = sub162(w[411a] + 2, b[412e], r2)
469eh addi word ptr [r12++], 4                   ; w[411a] += 4
46a0h mov word ptr [r12], r0                     ; w[411c] = sub162(w[411a] + 2, b[412e], r2)
46a2h jmp start_func ; x:sub_44dah

; loc_46a6h depuis 467e, 46be
46a6h addi word ptr [411ah], 2                   ; w[411a] +=2
46aah clc
46ach stX    
46aeh jc loc_46b4h ; x:loc_46b4h                 ; saute (break) si stX <=> stc (possibilité de boucle infinie)
46b0h jmp loc_45aeh ; x:loc_45aeh                ; saute

; loc_46b4h TODO
46b4h cmp r5, 3                                  ; r5 = w[4130]
46b8h jnz loc_45aeh ; x:loc_45aeh                ; saute si r5 != 3
; sinon r5 == 3
46bch and r11, r11                               ; 
46beh jz loc_46a6h ; x:loc_46a6h                 ; saute si r11 == 0
; sinon, r11 != 0

46c0h mov r10, 412eh                             ; r10 = OP_SIZE
46c4h mov r3, byte ptr [r10]                     ; r3 = b[412e]
46c6h mov r12, 411ah                             ; r12 = 0x411a
46cah mov r2, word ptr [412ch]                   ; r2 = w[412c]
46ceh mov r1, word ptr [r12]                     ; r1 = w[411a]
46d0h mov r0, word ptr [412ah]                   ; r0 = w[412a]
46d4h call sub_4848h ; x:sub_4848h               ; r0 = sub848(w[412a], w[411a], w[412c], b[412e], r4, r6)

46d8h mov word ptr [411eh], r0                   ; w[411e] = sub848(w[412a], w[411a], w[412c], b[412e], r4, r6)
46dch mov r1, word ptr [r12]                     ; r1 = w[411a]
46deh addi r1, 2                                 ; r1 = w[411a] + 2
46e0h mov r3, byte ptr [r10]                     ; r3 = b[412e]
46e2h mov r2, word ptr [412ch]                   ; r2 = w[412c]
46e6h mov r0, word ptr [412ah]                   ; r0 = sub848(w[412a], w[411a] + 2, w[412c], b[412e], r4, r6)
46eah call sub_4848h ; x:sub_4848h

46eeh addi word ptr [r12++], 4                   ; w[411a] += 4, r12 = CURRENT_BYTE
46f0h mov word ptr [r12], r0                     ; w[411c] = sub848(w[412a], w[411a] + 2, w[412c], b[412e], r4, r6)
46f2h mov word ptr [4142h], word ptr [412ah]     ; w[4142] = w[412a]
46f8h mov word ptr [4140h], word ptr [412ch]     ; w[4140] = w[412c]
46feh jmp start_func ; x:sub_44dah

; loc_4702h, (5 < sub268(3, v2) <= 7)
4702h mov r0, 6
4706h call read_nbitsh ; x:read_nbitsh        ; r0 = sub268(6, r2)
470ah mov r12, r0                         ; r12 = sub268(6, r2)
470ch mov r0, 3                           
4710h call read_nbitsh ; x:read_nbitsh        ; r0 = sub268(3, r2)

4714h mov r10, r0                         ; r10 = sub268(3, r2)
4716h and r12, r12                        
4718h jnz loc_473ah ; x:loc_473ah         ; saute si sub268(6, r2) != 0
; sinon, sub268(6, r2) == 0
471ah call decode_operandsh ; x:decode_operandsh        ; r0 = sub3c4(r2, r4, r6)
471eh cmp word ptr [4130h], 1             
4724h jz loc_473ah ; x:loc_473ah          ; saute si w[4130] == 1
; sinon, w[4130] != 1
4726h mov r5, word ptr [4126h]            ; r5 = w[4126]
472ah mov r10, r5                         ; r10 = w[4126]
472ch and r10, 7                          ; r10 = w[4126] & 7
4730h shr r5, 3                           ; r5 = w[4126] >> 3
4732h and r5, 1fffh                       ; r5 = (w[4126] >> 3) & 0x1fff
4736h mov word ptr [4126h], r5            ; w[4126] = (w[4126] >> 3) & 0x1fff

; loc_473ah depuis 4718h et 4724h
473ah and r14, 2                          ; r14 = r14 & 2
473eh jnz start_func ; x:sub_44dah        ; saute si r14 & 2 != 0
; sinon, r14 & 2 == 0
4742h cmp r13, 6                          ; 
4746h jz loc_47aeh ; x:loc_47aeh          ; saute si r13 == 6
; sinon, r13 != 6
4748h and r12, r12                        ; 
474ah jz loc_47a0h ; x:loc_47a0h          ; saute si r12 == 0
; sinon, r12 != 0
474ch mov r11, r12                        ; r11 = r12
474eh and r11, 20h                        ; r11 = r12 & 0x20
4752h and r12, 1fh                        ; r12 &= 0x1f
4756h and r11, r11                          
4758h jnz loc_4780h ; x:loc_4780h         ; saute si (r12 & 0x20) != 0
; sinon, r12 & 0x20 == 0
475ah mov r3, word ptr [411ch]            ; r3 = w[411c]
475eh add r3, r12                         ; r3 = w[411c] + r12
4760h mov r4, word ptr [411eh]            ; r4 = w[411e]
4764h add r4, r10                         ; r4 = w[411e] + r10
4766h mov r5, r4                          ; r5 = w[411e] + r10
4768h shr r5, 3                           ; r5 = (w[411e] + r10) >> 3
476ah and r5, 1fffh                       ; r5 = ((w[411e] + r10) >> 3) & 0x1fff
476eh add r3, r5                          ; r3 = w[411c] + r12 + ((w[411e] + r10) >> 3) & 0x1fff
4770h mov word ptr [411ch], r3            ; w[411c] = w[411c] + r12 + ((w[411e] + r10) >> 3) & 0x1fff
4774h and r4, 7                          
4778h mov word ptr [411eh], r4            ; w[411e] = w[411e] + r10
477ch jmp start_func ; x:sub_44dah

; loc_4780h depuis 4758h, (r12 & 0x20) != 0
4780h mov r9, 411ch                       ; r9 = CURRENT_BYTE
4784h mov r0, word ptr [r9]               ; r0 = w[411c]
4786h sub r0, r12                         ; r0 = w[411c] - r12
4788h mov r5, word ptr [411eh]            ; r5 = w[411e]
478ch cmp r5, r10                         
478eh jnc loc_4796h ; x:loc_4796h         ; saute si w[411e] >= r10
; sinon, w[411e] < r10
4790h subi r0, 1                          ; r0 = w[411c] - r12 - 1
4792h addi word ptr [411eh], 8            ; w[411e] += 8
4796h mov word ptr [r9], r0               ; w[411c] = w[411c] - r12 - 1
4798h sub word ptr [411eh], r10           ; w[411e] -= r10
479ch jmp start_func ; x:sub_44dah

; loc_47a0h depuis 474ah, r12 == 0
47a0h mov word ptr [411ch], word ptr [4126h]  ; w[411c] = w[4126]
47a6h mov word ptr [411eh], r10               ; w[411e] = r10
47aah jmp start_func ; x:sub_44dah

; loc_47aeh depuis 4746h, r13 == 6
47aeh mov r2, word ptr [4140h]           ; r2 = w[4140]
47b2h and r2, r2                         
47b4h jnz loc_47e0h ; x:loc_47e0h        ; saute si w[4140] != 0
; sinon, w[4140] == 0
47b6h mov r13, 411ah                     ; r13 = 0x411a
47bah mov r9, r13                        ; r9 = 0x411a
47bch mov r5, word ptr [r13++]           ; r5 = w[411a], r13 = CURRENT_BYTE
47beh subi r5, 2                         ; r5 = w[411a] - 2
47c0h mov r2, word ptr [r13++]           ; r2 = w[411c], r13 = CURRENT_BITS
47c2h mov r1, 1                          ; r1 = 1
47c6h mov r0, r5                         ; r0 = w[411a] - 2
47c8h call sub_4166h ; x:sub_4166h       ; r0 = sub166(w[411a] - 2, 1, w[411c])
47cch subi r5, 2                         ; r5 = w[411a] - 4
47ceh mov word ptr [r9], r5              ; w[411a] = w[411a] - 4
47d0h mov r2, word ptr [r13]             ; r2 = w[411e]
47d2h mov r1, 1                          ; r1 = 1
47d6h mov r0, r5                         ; r0 = w[411a] - 4
47d8h call sub_4166h ; x:sub_4166h       ; r0 = sub166(w[411a] - 4, 1, w[411e])
47dch jmp loc_4748h ; x:loc_4748h

; loc_47e0h depuis 47b4h,  w[4140] != 0
47e0h mov r13, 411ah                     ; r13 = 0x411a
47e4h mov r9, r13                        ; r9 = 0x411a
47e6h mov r1, word ptr [r13++]           ; r1 = w[411a], r13 = CURRENT_BYTE
47e8h subi r1, 2                         ; r1 = w[411a] - 2
47eah mov r3, 1                          ; r3 = 1
47eeh mov r4, word ptr [r13++]           ; r4 = w[411c], r13 = CURRENT_BITS
47f0h mov r0, word ptr [4142h]           ; r0 = w[4142]
47f4h call sub_484ch ; x:sub_484ch       ; r0 = sub84c(w[4142], w[411a] - 2, r2, 1, w[411c], r6)
47f8h subi r1, 2                         ; r1 =  w[411a] - 4
47fah mov word ptr [r9], r1              ; w[411a] = w[411a] - 4
47fch mov r3, 1                          ; r3 = 1
4800h mov r4, word ptr [r13]             ; r4 = w[411e]
4802h mov r2, word ptr [4140h]           ; r2 = w[4140]
4806h mov r0, word ptr [4142h]           ; r0 = w[4142]
480ah call sub_484ch ; x:sub_484ch       ; r0 = sub84c(w[4142], w[411a] - 4, w[4140], 1, w[411e], r6)
480eh jmp loc_4748h ; x:loc_4748h

4812h ret
asm}}}*/
void do_instruction(void) {
	uint16_t r0, r10, r11, r12;
	int carry;
	uint16_t old_flags, new_flags;

	uint16_t lr, shift, pc_bytes, pc_bits;
	uint8_t opcode, op_type; 
	uint8_t cond, orig_cond_bits, cond_bits, uf, flags, reg;


start_4da:
	sw(SAVED_OFF_ADDR, rw(0x411a));

	/* sauvegarde du program counter */
	sw(SAVED_OFF_DEST, rw(CURRENT_BYTE));
	sw(SAVED_OFF_SRC, rw(CURRENT_BITS));

	pc_bytes = rw(CURRENT_BYTE);
	pc_bits = rw(CURRENT_BITS);

	cond = read_nbits(1) & 1;
	cond_bits = read_nbits(8);
	orig_cond_bits = cond_bits;

	if (cond_bits == 0xff)
		return;

	flags = rw(FLAGS);

	/* remise à zéro des bits de condition et des flags pour être sûr de pas vérifier */
	if (cond == 0) {
		cond_bits >>= 4;
		flags >>= 4;
	}

	// 4518h -> 4538h, lol !
	if (test_flags(cond_bits & 0xf, flags & 0xf) == 0) {
		cond += 2;
	}

	r11 = 0;
	opcode = read_nbits(3);
	uf  = read_nbits(1);

	sw(SRC_VALUE, 0);

	debug(CRIT, "\n-> PC = (%d, %d), cond = %x, cond_bits = %x:%x, flags = %x:%x, ins = %s, uf = %x",
			pc_bytes, pc_bits, cond, orig_cond_bits >> 4, orig_cond_bits & 0xf,
			rw(FLAGS) >> 4, rw(FLAGS) & 0xf, instructions[opcode], uf);

	switch (opcode) {
		case 0:
		case 1:
			// 4574h, r13 <= 2 && r13 != 2 <=> r13 == 1
			decode_operands();
			set_dest_operand();
			decode_operands();

			if (opcode != 0) {
				r0 = rw(DST_VALUE) | rw(SRC_VALUE);
				debug(CRIT, "0x%x | 0x%x = 0x%x", rw(SRC_VALUE), rw(DST_VALUE), r0 );
			} else {
				r0 = rw(DST_VALUE) & rw(SRC_VALUE);
				debug(CRIT, "0x%x & 0x%x = 0x%x", rw(SRC_VALUE), rw(DST_VALUE), r0 );
			}
			update_flags(ZERO(r0), 0, SIGN(r0));

			old_flags = rw(FLAGS);
			sub_4814(uf, cond);
			/* ne met à jour que le flag zero */
			new_flags = (rw(FLAGS) & 0xff11) | (old_flags & 0xffee);
			sw(FLAGS, new_flags);

			sw(SRC_VALUE, r0);

			goto loc_45ae;

		case 2:
			// 45beh, r13 == 2
			decode_operands();
			set_dest_operand();
			r0 = ~rw(SRC_VALUE);
			debug(CRIT, "~0x%x = 0x%x", rw(SRC_VALUE), r0);
			sw(SRC_VALUE, r0);
			update_flags(ZERO(r0), 0, SIGN(r0));
			sub_4814(uf, cond);

			goto loc_45ae;

		case 3:
			// 45d0h, r13 <= 4 && r13 > 2 && r13 != 4 <=> r13 == 3
			lr = read_nbits(1);
			shift = read_nbits(8);

			decode_operands();
			set_dest_operand();

			r0 = rw(SRC_VALUE);
			if (lr == 1) {
				// 45f6h
				// last shifted bit
				carry = (r0 >> (shift - 1)) & 1;
				r0 >>= shift;
				debug(CRIT, "0x%x >> %d = 0x%x", rw(SRC_VALUE), shift, r0);
			} else {
				// 4600
				// last shifted bit
				carry = (r0 >> (16 - shift)) & 1;
				r0 <<= shift;
				debug(CRIT, "0x%x << %d = 0x%x", rw(SRC_VALUE), shift, r0);
			}
			sw(SRC_VALUE, r0);
			update_flags(ZERO(0), carry, 0);
			sub_4814(uf, cond);

			goto loc_45ae;

		case 4:
			// 460ah, r13 == 4
			/* décode l'opérande destination */
			decode_operands();
			op_type = rb(SRC_TYPE);
			reg = rw(SRC_REG);

			if ( (op_type == OP_TYPE_REG) && (reg == 15) )
				r11 += 1;

			if (reg == 14) {
				if ( (op_type == 3) ||
						( (op_type == OP_TYPE_MEMREF) && (rw(OP_MEMREF_TYPE) == 0) ) ) {
					if (!COND_MATCHED(cond)) {
						sw(0x411a, rw(0x411a) - 2);
						sw(SRC_MEM_ADDR, rw(SRC_MEM_ADDR) - 2);
					}
				}
			}
			// 464ch
			set_dest_operand();

			/* décode l'opérande source */
			decode_operands();

			if (!COND_MATCHED(cond))
				goto start_4da;

			if (rw(SRC_REG) != 14)
				goto loc_45ae;

			if (rw(SRC_TYPE) != 2)
				goto loc_46b4;

			// 4672h
			if (rw(OP_MEMREF_TYPE) != 0)
				goto loc_45ae;

			if (r11 == 0) {
				// loc_46a6h, r11 == 0
				addw(0x411a, 2);
				goto loc_46b4;
			}

			// 4680h, r14 & 2 == 0, buf_126[1] == 0x0e, buf_126[5] == 2, buf_126[6] == 0, r11 != 0
			sw(CURRENT_BITS, sub_4162(rw(0x411a), rb(SRC_SIZE)));
			sw(CURRENT_BYTE, sub_4162(rw(0x411a) + 2, rb(SRC_SIZE)));
			addw(0x411a, 4);
			goto start_4da;

		case 5:
		case 6:
		case 7: // jump ?
			// 4702h, r13 <= 7 && r13 > 4 <=> 5 <= r13 <= 7  TODO
			r12 = read_nbits(6);
			r10 = read_nbits(3);

			if (r12 == 0) {
				// 471ah
				decode_operands();
				if (rw(SRC_TYPE) != OP_TYPE_IMMEDIATE) {
					// 4726h
					r10 = rw(SRC_VALUE) & 7;
					sw(SRC_VALUE, (rw(SRC_VALUE) >> 3) & 0x1fff);
				}
			}
			// 473ah
			if (!COND_MATCHED(cond)) {
				debug(INFO, "condition not matched\n");
				goto start_4da;
			}

			if (opcode == 6) {
				// 47aeh, r13 == 6
				if (rw(0x4140) == 0) {
					// 47b6h
					sub_4166(rw(0x411a) - 2, 1, rw(CURRENT_BYTE));
					sw(0x411a, rw(0x411a) - 4);
					sub_4166(rw(0x411a), 1, rw(CURRENT_BITS));
				} else {
					// 47e0h
					sub_484c(rw(0x4142), rw(0x411a) - 2, rw(0x4140), 1, rw(CURRENT_BYTE));
					sw(0x411a, rw(0x411a) - 4);
					sub_484c(rw(0x4142), rw(0x411a), rw(0x4140), 1, rw(CURRENT_BITS));
				}
			}

			if (r12 != 0) {
				// 474ch
				r11 = r12 & 0x20;
				r12 &= 0x1f;
				if (r11 == 0) {
					// 475ah
					addw(CURRENT_BYTE, r12 + ( ((rw(CURRENT_BITS) + r10) >> 3) & 0x1fff ));
					sw(CURRENT_BITS, (rw(CURRENT_BITS) + r10) & 7);
					goto start_4da;
				} else {
					// 4780h
					r0 = rw(CURRENT_BYTE) - r12;
					if (rw(CURRENT_BITS) < r10) {
						r0 = rw(CURRENT_BYTE) - r12 - 1;
						addw(CURRENT_BITS, 8);
					}
					sw(CURRENT_BYTE, r0);
					sw(CURRENT_BITS, rw(CURRENT_BITS) - r10);
					goto start_4da;
				}
			} else {
				// 47a0h, r13 != 6, r12 == 0
				sw(CURRENT_BYTE, rw(SRC_VALUE));
				sw(CURRENT_BITS, r10);
				goto start_4da;
			}

		default:
			goto start_4da;
	}

loc_46b4:
	if (rw(SRC_TYPE) == 3) {
		// 46bch
		if (r11 != 0) {
			// 46c0h
			sw(CURRENT_BITS,
					sub_4848(rw(SRC_MEM_ADDR), rw(0x411a), rw(SRC_OBF_VALUE), rb(SRC_SIZE)));
			sw(CURRENT_BYTE,
					sub_4848(rw(SRC_MEM_ADDR), rw(0x411a) + 2, rw(SRC_OBF_VALUE), rb(SRC_SIZE)));
			addw(0x411a, 4);
			sw(0x4142, rw(SRC_MEM_ADDR));
			sw(0x4140, rw(SRC_OBF_VALUE));
			goto start_4da;
		} else {
			// 46a6h
			addw(0x411a, 2);
			// 45aeh si stX <=> nop
		}
	}

loc_45ae:
	if (COND_MATCHED(cond))
		save_dest();
	goto start_4da;

}

/*{{{asm sub_814(r6, r14)
  4814h int 49h
  4816h mov r0, word ptr [0c000h]      ; charge les flags I S O C Z dans r0
  481ah and r0, 0fh                    ; r0 &= 0x0f
  481eh and r6, r6                     
  4820h jz loc_exit ; x:loc_4844h     ; saute si r6 == 0
  ; sinon, r6 != 0
  4822h mov r12, r14                  ; r12 = r14
  4824h and r12, 2                    ; r12 = r14 & 2
  4828h jnz loc_exit ; x:loc_4844h    ; saute si r14 & 2 != 0
  ; sinon, r14 & 2 == 0
  482ah mov r12, word ptr [4144h]     ; r12 = word_4144
  482eh and r14, r14                  ; 
  4830h jz loc_4838h ; x:loc_4838h    ; saute si r14 == 0
  ; sinon, r14 != 0
  4832h and r12, 0f0h                 ; r12 = word_4144 & 0xf0
  4836h jmp loc_483eh ; x:loc_483eh   ; 

  4838h shl r0, 4                     ; r0 <<= 4
  483ah and r12, 0fh                  ; r12 = word_4144 & 0x0f

  483eh or r12, r0                    ; r12 |= r0
  4840h mov word ptr [4144h], r12     ; word_4144 = r12

  ;loc_exit:
  4844h int 4ah
  4846h ret
  asm}}}*/

void sub_4814(uint16_t uf, uint16_t cond) {
	uint16_t cy16flags, vmflags;
	cy16flags = rw(0xc000) & 0xf;

	//printf("-> sub_4814(0x%x, 0x%x), r0 = %x\n", v6, r14, r0);

	if (uf == 0)
		return;

	/* teste si cond test le flag carry */
	if ((cond & 2) != 0)
		return;

	vmflags = rw(FLAGS);

	if (cond == 0) {
		// 4838
		cy16flags <<= 4;
		vmflags &= 0x0f;
	} else {
		// 4832
		vmflags &= 0xf0;
	}

	// 483e
	vmflags |= cy16flags;
	sw(FLAGS, vmflags);
}

/*{{{asm sub_848(v0, v1, v2, v3, v4, v6) -> r0
  4848h addi r3, 1
  484ah shl r3, 1

  484ch int 49h
  484eh mov r5, r2     ; r5 = v2
  4850h shl r5, 6      ; r5 = v2 << 6
  4852h add r5, r2     ; r5 = ( v2 << 6) + v2
  4854h shl r5, 4      ; r5 = ( (v2 << 6) + v2 ) << 4
  4856h add r5, r2     ; r5 = ( ( (v2 << 6) + v2 ) << 4 ) + v2
  4858h xor r5, 464dh  ; r5 = ( ( ( (v2 << 6) + v2 ) << 4 ) + v2 ) ^ 0x464d

  485ch mov r2, r0     ; r2 = v0
  485eh xor r2, 6c38h  ; r2 = v0 ^ 0x6c38
  4862h add r0, r1     ; r0 = v0 + v1
  4864h addi r1, 2     ; r1 = v1 + 2

  4866h mov r7, r6     ; r7 = r6
  4868h rol r5, 1      ; r5 = rol(r5, 1)
  486ah ror r2, 2      ; r2 = ror(r2, 2)
  486ch add r2, r5     ; r2 += r5
  486eh addi r5, 2     ; r5 += 2
  4870h mov r6, r2     ; r6 = r2
  4872h xor r6, r5     ; r6 = r2 ^ r5
  4874h mov r8, r6     ; r8 = r2 ^ r5
  4876h shr r8, 8      ; r8 = (r2 ^ r5) >> 8
  4878h and r8, 0ffh   ; r8 = ((r2 ^ r5) >> 8) & 0xff
  487ch and r6, 0ffh   ; r6 = (r2 ^ r5) & 0xff
  4880h xor r6, r8     ; r6 = ((r2 ^ r5) & 0xff) ^ (((r2 ^ r5) >> 8) & 0xff)
  4882h subi r1, 1     ; r1 -= 1
  4884h jnz loc_4866h ; x:loc_4866h ; saute si r1 != 0
  ; sinon, r1 == 0
  4886h shl r6, 8       ; r6 = r6 << 8
  4888h or r6, r7       ; r6 = (r6 << 8) | r7
  488ah mov r1, r3     
  488ch mov r2, r4
  488eh xor r2, r6      ; r2 = v4 ^ r6
  4890h call sub_4166h ; x:sub_4166h ; r0 = sub_4166(v0 + v1, v3, r2)
  4894h xor r0, r6       ; r0 = r0 ^ r6
  4896h and r3, 4        ; r3 = v3 & 4
  489ah jnz loc_48a0h ; x:loc_48a0h ; saute si v3 & 4 != 0
  ; sinon, v3 & 4 == 0
  489ch and r0, 0ffh  ; r0 &= 0xff
  48a0h mov word ptr [sp + 1ch], r0
  48a4h int 4ah 
  48a6h ret          ; return r0
  asm}}}*/

/* get a byte or word at address addr */
uint16_t sub_4848(uint16_t addr, uint16_t regv, uint16_t opv, uint16_t size) {
	return sub_484c(addr, regv, opv, (size + 1) << 1, 0);
}

/* get or set a byte / word at address addr */
uint16_t sub_484c(uint16_t addr, uint16_t regv, uint16_t opv, uint16_t op, uint16_t value) {
	uint16_t ret, r2, r5, r6 = 0, r7, r8;
	int i;

	r5 = (( ( (opv << 6) + opv) << 4 ) + opv) ^ 0x464d;

	r2 = addr ^ 0x6c38;
	for (i = 0; i < regv + 2; i++) {
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

	ret = sub_4166(addr + regv, op, value ^ r6) ^ r6;

	if (op != DO_GET_WORD)
		ret &= 0xff;

	return ret;
}


