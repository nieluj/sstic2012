#include <stdint.h>

#define BASE_ADDR 0x4000
#define MEM_SIZE 0x10000

#define ROL(x,b) (((x) << (b)) | ((x) >> (16 - (b))))
#define ROR(x,b) (((x) >> (b)) | ((x) << (16 - (b))))
#define GET_BYTE(i) ( sub_4162((i), 0) )
#define KEEP_NBITS(v,s) ((v) & ~( 0xffff << (s)))
#define ZERO(v) ( (v) == 0 )
#define SIGN(v) ( ((v) >> 15) & 1 )

#define rw(addr) ( m[(addr)] | m[(addr) + 1] << 8 )
#define sw(addr,v) do {                  \
  uint16_t _tmp_ = (v) ;                 \
  m[(addr)] = _tmp_ & 0xff;              \
  m[(addr) + 1] = ( _tmp_ >> 8 ) & 0xff; \
} while(0)

#define addw(addr, v) do {       \
  uint16_t __tmp__ = rw((addr)); \
  __tmp__ += (v);                \
  sw( (addr), __tmp__ );         \
} while(0)

#define orw(addr, v) sw((addr), rw((addr)) | (v))
#define incw(addr) addw(addr, 1)
#define rb(addr)   ( m[(addr)] )
#define sb(addr, v) m[(addr)] = (v) & 0xff

#define cnta(i) (0x4054 + 2 * (i) )

typedef uint16_t puint16_t;

void do_mem_init(void);
void do_server_init(void);
void clear_mem(void);

struct usb_req {
    uint8_t  mrequest;
    uint8_t  request;
    uint16_t value;
    uint16_t index;
    uint16_t length;
};

/** forward declaration **/
/* structures */
struct endpoint_desc;
typedef void (*callback_t)(struct endpoint_desc *endpoint);

struct endpoint_desc {
    void     *nextlink;
    uint16_t address;
    uint16_t length;
    callback_t callback;
};

/* functions */

void handle_usb_vendor_int(struct usb_req *req);

void handle_receive_req(struct usb_req *req);
int do_susb1_receive_int(struct endpoint_desc *endpoint);
void susb1_receive_int_callback(struct endpoint_desc *endpoint);

void handle_send_req(struct usb_req *req);
int do_susb1_send_int(struct endpoint_desc *endpoint);
//void susb1_send_int_callback(struct endpoint_desc *endpoint);
void sub_40e8(struct endpoint_desc *endpoint);

void do_susb1_finish_int(void);

/* read memory */
uint16_t sub_4162(uint16_t addr, uint16_t size);

/* set a value in memory */
uint16_t sub_4166(uint16_t addr, uint16_t op, uint16_t value);

uint16_t sub_41a6(uint16_t v0, uint16_t v1, uint16_t v2);
puint16_t sub_41da(uint16_t v0, uint16_t c1);

/* right shift */
uint16_t sub_4146(uint16_t r0, uint16_t r1); // 0x4146

/* left shift */
uint16_t sub_4156(uint16_t r0, uint16_t r1); // 0x4156

/* update flags */
void sub_4814(uint16_t uf, uint16_t cond);

/* read a obfuscated value */
uint16_t sub_4848(uint16_t addr, uint16_t regv, uint16_t opv, uint16_t size);

/* set a obfuscated value */
uint16_t sub_484c(uint16_t addr, uint16_t regv, uint16_t opv, uint16_t op, uint16_t value);

void save_dest(void);
void do_instruction(void);
uint16_t read_nbits(uint16_t needed);
void set_dest_operand(void);
void decode_operands(void);
