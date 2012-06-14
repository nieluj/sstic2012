#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
#include <openssl/rc4.h>
#include <openssl/md5.h>

#define BLOCK_SIZE 4096
#define SECRET_SIZE 1048592
#define SECRET_REAL_BLOCK_COUNT 257

#define START_BLOCK 26625
#define END_BLOCK (START_BLOCK + SECRET_REAL_BLOCK_COUNT + 1) /* + 1 for excluded block */
#define EXCLUDED_BLOCK 26637

#define KEY "fd4185ff66a94afde5df94e3f63d8937"

#define handle_error(msg) \
  do { perror(msg); exit(EXIT_FAILURE); } while (0)

#define abs(x) ((x) < 0 ? - (x) : (x))

unsigned char buf_in[SECRET_REAL_BLOCK_COUNT * BLOCK_SIZE];
unsigned char buf_out[SECRET_REAL_BLOCK_COUNT * BLOCK_SIZE];

void do_rc4(unsigned char *dst, unsigned char *src, unsigned long len) {
    RC4_KEY key;
    unsigned int i = 1;

    RC4_set_key(&key, 32, (unsigned char *) KEY);

    for (i=1; i < len; i++)
    	src[i-1] = src[i-1] ^ src[i];

    RC4(&key, len, src, dst);
}

int main(int argc, char **argv) {
    unsigned char md5[16];
    char *partition_path, *output_path;
    int i, j;
    int fd;
    struct stat sb;
    unsigned char *addr;

    if (argc != 3) {
    	printf("usage: %s <partition file path> <output path>\n", argv[0]);
    	exit(EXIT_FAILURE);
    }

    partition_path = argv[1];
    output_path = argv[2];

    fd = open(partition_path, O_RDONLY);
    if (fd == -1)
        handle_error("open");

    if (fstat(fd, &sb) == -1)
        handle_error("fstat");

    addr = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (addr == MAP_FAILED)
        handle_error("mmap");
    close(fd);

    for (i = START_BLOCK, j = 0; i <= END_BLOCK; i++) {
    	if (i == EXCLUDED_BLOCK)
    	    continue;

	memcpy(buf_in + j * BLOCK_SIZE, addr + i * BLOCK_SIZE, BLOCK_SIZE);
    	j++;
    }
    munmap(addr, sb.st_size);
 
    MD5(buf_in + 16, SECRET_SIZE - 16, md5);

    if (memcmp(md5, buf_in, 16) != 0) {
    	fprintf(stderr, "warning, md5 mismatch\n");
    	exit(EXIT_FAILURE);
    }
    printf("[+] md5 ok, decrypting to %s\n", output_path);

    do_rc4(buf_out, buf_in + 16, SECRET_SIZE - 16);

    fd = open(output_path, O_WRONLY | O_CREAT, S_IRWXU);
    if (fd == -1)
        handle_error("open");
    write(fd, buf_out, SECRET_SIZE - 16);
    close(fd);

    exit(EXIT_SUCCESS);
}
