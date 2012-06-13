#include <stdio.h>
#include <ctype.h>

char hc[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' }; 

char hexbuf[32 + 1];

int verbose_level = 0;

void bin_to_hex(char *dst, char *src, int len) {
  int i;
  for (i=0; i < len; i++) {
      dst[2*i]   = hc[(src[i] >> 4) & 0xf];
      dst[2*i+1] = hc[src[i] & 0xf];
  }
  dst[2*len] = '\0';
}

void hexdump(void *ptr, int buflen) {
  unsigned char *buf = (unsigned char*)ptr;
  int i, j;
  for (i=0; i<buflen; i+=16) {
    printf("%06x: ", i);
    for (j=0; j<16; j++) 
      if (i+j < buflen)
        printf("%02x ", buf[i+j]);
      else
        printf("   ");
    printf(" ");
    for (j=0; j<16; j++) 
      if (i+j < buflen)
        printf("%c", isprint(buf[i+j]) ? buf[i+j] : '.');
    printf("\n");
  }
}
