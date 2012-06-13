#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>

#include "server.h"

extern uint8_t *m;
extern int jmp_set;


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

}

void do_test(void) {
    uint16_t t = 0xffff;
    printf("[?] doing basic tests\n");
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
    printf("v = 0x%04x, 0x%04x\n", rw(0x4004), t);
    assert(rw(0x4004) == 0);

    printf("[+] basic tests passed\n");
}

int main(int argc, char **argv) {
    do_mem_init();
    do_server_init();

    do_test();
    do_func_test();
    exit(EXIT_SUCCESS);
}

