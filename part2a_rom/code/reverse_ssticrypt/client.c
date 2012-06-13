#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
//#include <usb.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <ctype.h>
#include <unistd.h>

#include "client.h"
#include "server.h"
#include "utils.h"

#define USB_TYPE_VENDOR 1
#define USB_ENDPOINT_IN 1
#define USB_ENDPOINT_OUT 1

extern uint8_t *from_client;

char blob[0x100];
char blah[0x20];

uint8_t *ram;
uint8_t *all_layers[3];
uint8_t *layers_buf[3];

uint16_t layers_len[] = { 0x65a, 0xEE2, 0x6E3 };

void vicpwn_quit(int i) {
    puts("exiting...");
    exit(0);
}

void load_layer(void *layer, int nlayer, int offset) {
    memcpy(ram + offset, layer, layers_len[nlayer]);
    if (nlayer > 0) {
        //free(layer);
    }
}

void swap_key(uint32_t *key) {
    uint32_t k = *key;
    uint8_t b0, b1, b2, b3;

    b0 = (k >> 24) & 0xff;
    b1 = (k >> 16) & 0xff;
    b2 = (k >>  8) & 0xff;
    b3 = (k      ) & 0xff;

    *key =  (b0 << 16) | (b1 << 24) | (b3 << 8) | b2;
}

void set_my_key(char *key, int nlayer, int offset) {
	uint8_t buf[20];
	uint32_t ret;

	strcpy((char *) buf, key);

	/* 8, 12, 16 */
	buf[ 4 * (nlayer + 2) ] = 0;
	ret = htonl(strtoul( (char *) buf + 4 * nlayer , 0, 16));

	swap_key(&ret);
	memcpy(ram + offset, &ret, 4);
	if (nlayer == 1) {
		memcpy(ram + offset + 16, blob, 0x100);
	} else if (nlayer == 2) {
		memcpy(ram + offset + 16, blah, 0x20);
	}
}

static uint16_t swap_word(uint16_t w) {
    uint8_t b1, b2;

    b1 = (uint8_t) (w & 0xff);
    b2 = (uint8_t) ( (w >> 8) & 0xff );

    return (b1 << 8) | b2 ;
}

void *vicpwn_check(int nlayer, int addr, char *key) {
	int next_layer_id = nlayer + 1;
	unsigned int next_layer_len = layers_len[next_layer_id];
	uint8_t *orig_next_layer = all_layers[next_layer_id];
	uint32_t l, dwmem, dwkey;
	uint8_t i, j, k;
	uint8_t tmpbuf[16], S[256];

	uint8_t *next_layer = layers_buf[next_layer_id];
	uint32_t *next_layer32, *orig_next_layer32;

	memcpy(&dwmem, ram + addr, 4);
	swap_key(&dwmem);

	strncpy((char *) tmpbuf, key, 16);
	tmpbuf[8] = 0;

	dwkey = htonl(strtoul((char *) tmpbuf, 0, 16));

	switch(nlayer) {
		case 0:
			next_layer32 = (uint32_t *) next_layer;
			orig_next_layer32 = (uint32_t *) orig_next_layer;

			next_layer32[0] = orig_next_layer32[0] ^ dwmem;
			for (l=1; l < (next_layer_len/4) ; l++)
				next_layer32[l] = orig_next_layer32[l] ^ next_layer32[l-1];

			if (dwmem != dwkey) {
				fprintf(stderr, "[+] validation passed for layer 0, mem = %x, key = %x\n",
						dwmem, dwkey);
				return next_layer;
			} else {
				fprintf(stderr, "[+] bad key for layer 0\n");
				exit(EXIT_FAILURE);
			}
		case 1:
			memcpy(S, ram + addr + 16, 256);
			if (S[254] == 0xff && S[255] == 0xff) {
				fprintf(stderr, "[+] bad key for layer 1\n");
				exit(EXIT_FAILURE);
			} else {
				fprintf(stderr, "[+] validation passed for layer 1, mem = %x, key = %x\n",
						dwmem, dwkey);
			}
			i = 0; j = 0;
			/* RC4 */
			for (l = 0; l < next_layer_len; l++) {
				i = (i + 1) % 256;
				j = (j + S[i]) % 256;
				k = S[i];
				S[i] = S[j];
				S[j] = k;
				next_layer[l] = orig_next_layer[l] ^ S[ (S[i] + S[j]) % 256 ];
			}

			return next_layer;
		case 2:
			if (!strncmp((char *) ram + addr + 16, "V29vdCAhISBTbWVsbHMgZ29vZCA6KQ==", 0x20)) {
				fprintf(stderr, "[+] validation passed for layer 2, mem = %x, key = %x\n",
						dwmem, dwkey);
				exit(EXIT_SUCCESS);
			} else {
				fprintf(stderr, "[+] bad key for layer 2\n");
				exit(EXIT_FAILURE);
			}
		default:
			return next_layer;
	}
}

static inline int usb_control_msg(int requesttype, int request, int value, int index, char *bytes, int size, int timeout) {
    struct usb_req ureq;
    int ret;

    ureq.mrequest = requesttype;
    ureq.request = request;
    ureq.value = value;
    ureq.index = index;
    ureq.length = size;

    if (request == 0x51) {
        memcpy(from_client, bytes, size);
        handle_usb_vendor_int(&ureq);
        ret = 0;
    } else if (request == 0x56) {
        handle_usb_vendor_int(&ureq);
        memcpy(bytes, from_client, size);
        ret = 20;
    }
    return ret;
}

int vicpwn_handle(char *key) {
	char buf[20];
	uint8_t *layer;
	int i, ret;
	uint16_t off_src, off_dst;

	off_src = 0;
	layer = all_layers[0];

	for (i=0; i < 3; i++) {
		load_layer(layer, i, 0);
		set_my_key(key, i, 0xa000);

		while ( *(int *)(ram + 0x8000) == 0  || off_src != 0 ) {
			off_src &= 0xfff0;
			if (off_src != 0xfff0) {
				memcpy(buf, ram + off_src, 16);
				usb_control_msg(USB_TYPE_VENDOR | USB_ENDPOINT_OUT,
						0x51, off_src, 1, buf, 16, 1000);
			}

			ret = usb_control_msg(USB_TYPE_VENDOR | USB_ENDPOINT_IN,
					0x56, 0, 0, buf, 20, 1000);

			off_dst = (buf[ret-4] & 0xff) | ( (buf[ret-4+1] & 0xff) << 8);
			off_src = (buf[ret-2] & 0xff) | ( (buf[ret-2+1] & 0xff) << 8);

			if ( (off_dst & 0xfff0) == 0xfff0)
				continue;

			if ( (off_dst & 1) == 0)
				continue;

			off_dst &= 0xfff0;
			memcpy(ram + off_dst, buf, 16);
		}
		layer = vicpwn_check(i, 0xa000, key);
		if (!layer)
			return -1;

		*(int *)(ram + 0x8000) = 0;
	}
	return 0;
}

int check_key(char *key, int id) {
    signal(SIGINT, vicpwn_quit);
    return vicpwn_handle(key);
}

int client_init_done = 0;

void do_client_init(void) {
    int fd, i;
    ssize_t ret;

    if (client_init_done)
    	return;

    ram = malloc(0x10000);

    for (i=0; i < 3; i++) {
	layers_buf[i] = malloc(layers_len[0] * sizeof(uint8_t));
    }

    all_layers[0] = malloc(layers_len[0] * sizeof(uint8_t));
    fd = open(DATA_PATH "layer1", O_RDONLY);
    if (fd == -1)
    	handle_error("open");
    ret = read(fd, all_layers[0], layers_len[0]);
    close(fd);

    all_layers[1] = malloc(layers_len[1] * sizeof(uint8_t));
    fd = open(DATA_PATH "layer2", O_RDONLY);
    if (fd == -1)
    	handle_error("open");
    ret = read(fd, all_layers[1], layers_len[1]);
    close(fd);

    all_layers[2] = malloc(layers_len[2] * sizeof(uint8_t));
    fd = open(DATA_PATH "layer3", O_RDONLY);
    if (fd == -1)
    	handle_error("open");
    ret = read(fd, all_layers[2], layers_len[2]);
    close(fd);

    fd = open(DATA_PATH "blah", O_RDONLY);
    if (fd == -1)
    	handle_error("open");
    ret = read(fd, blah, 0x20);
    close(fd);

    fd = open(DATA_PATH "blob", O_RDONLY);
    if (fd == -1)
    	handle_error("open");
    ret = read(fd, blob, 0x100);
    close(fd);

    client_init_done = 1;
}
