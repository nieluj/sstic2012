/* vim: set noet ts=4 sw=4: */
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

#define MD5_LEN 16

#define PART_BLOCK_COUNT 261048
#define BLOCK_SIZE 4096
#define SECRET_REAL_BLOCK_COUNT 257

#define MAX_CANDIDATES 65535

#define START_BLOCK 26625
#define END_BLOCK 26882

#define KEY "fd4185ff66a94afde5df94e3f63d8937"

#define handle_error(msg) \
	do { perror(msg); exit(EXIT_FAILURE); } while (0)

#define abs(x) ((x) < 0 ? - (x) : (x))

unsigned char buf_in[BLOCK_SIZE * SECRET_REAL_BLOCK_COUNT];
unsigned char tmp[BLOCK_SIZE * SECRET_REAL_BLOCK_COUNT];
unsigned char buf_out[BLOCK_SIZE * SECRET_REAL_BLOCK_COUNT];

double entropy(uint8_t *buf, int size) {
	double ret = 0.0;
	int byte_counts[256];
	int i;

	memset(byte_counts, 0, sizeof(int) * 256);
	for (i = 0; i < size; i++)
		byte_counts[buf[i]]++;

	for (i = 0; i < 256; i++) {
		double p_i = (double) byte_counts[i] / (double) size;
		if (p_i > 0.0)
			ret -= p_i * (log(p_i) / log(2));
	}

	return ret;
}

void do_rc4(unsigned char *dst, unsigned char *src, unsigned long len) {
	RC4_KEY key;
	unsigned int i;

	memcpy(tmp, src, len);

	RC4_set_key(&key, 32, (unsigned char *) KEY);

	for (i=1; i < len; i++)
		tmp[i-1] = tmp[i-1] ^ tmp[i];

	RC4(&key, len, tmp, dst);
}

void findblocks(char *partition_path) {
	double candidates_entropy[MAX_CANDIDATES];
	int candidates[MAX_CANDIDATES];
	int candidates_count = 0;
	int found_blocks[SECRET_REAL_BLOCK_COUNT];

	int block_index, block_found;
	int i, k, fd;
	struct stat sb;
	unsigned char *addr;
	double block_entropy, new_entropy, entropy_diff, new_entropy_diff;

	printf("[+] mmap'ing the partition file\n");

	fd = open(partition_path, O_RDONLY);
	if (fd == -1)
		handle_error("open");

	if (fstat(fd, &sb) == -1)
		handle_error("fstat");

	addr = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (addr == MAP_FAILED)
		handle_error("mmap");
	close(fd);

	for (i = 0; i < PART_BLOCK_COUNT; i++) {
		block_entropy = entropy(addr + i * BLOCK_SIZE, BLOCK_SIZE);
		if (block_entropy > 7.8) {
			candidates_entropy[candidates_count] = block_entropy;
			candidates[candidates_count++] = i;
		}

		if (candidates_count > MAX_CANDIDATES) {
			fprintf(stderr, "too many candidates found\n");
			munmap(addr, sb.st_size);
			exit(EXIT_FAILURE);
		}
	}

	printf("[+] found %d block candidates\n", candidates_count);

	for (i=0; i < SECRET_REAL_BLOCK_COUNT; i++) {
		block_found = 0;
		entropy_diff = 0;
		for (k = 0; k < candidates_count; k++) {
			block_index = candidates[k];
			block_entropy = candidates_entropy[k];

			if (block_entropy == 0.0) {
				continue;
			}

			memcpy(buf_in + i * BLOCK_SIZE, addr + block_index * BLOCK_SIZE, BLOCK_SIZE);
			do_rc4(buf_out, buf_in + MD5_LEN, (BLOCK_SIZE * (i + 1)) - MD5_LEN);
			new_entropy = entropy(buf_out + i * BLOCK_SIZE, BLOCK_SIZE);

			/* ne devrait pas arriver */
			if (new_entropy > block_entropy) {
				continue;
			}
			new_entropy_diff = block_entropy - new_entropy;
			if (new_entropy_diff > entropy_diff) {
				block_found = k;
				entropy_diff = new_entropy_diff;
			}
		}

		found_blocks[i] = candidates[block_found];
		candidates_entropy[block_found] = 0.0;

		printf("position %03d => block %06d, entropy diff = %f\n", i, found_blocks[i], entropy_diff);
		memcpy(buf_in + i * BLOCK_SIZE, addr + found_blocks[i] * BLOCK_SIZE, BLOCK_SIZE);
	}

}

int main(int argc, char **argv) {
	if (argc != 2) {
		printf("usage: %s <partition file path>\n", argv[0]);
		exit(EXIT_FAILURE);
	}
	findblocks(argv[1]);
	exit(EXIT_SUCCESS);
}
