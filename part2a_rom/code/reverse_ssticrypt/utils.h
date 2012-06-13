extern char hexbuf[32 + 1];
extern int verbose_level;

void bin_to_hex(char *dst, char *src, int len);
void hexdump(void *ptr, int buflen);

#define handle_error(msg) \
  do { perror(msg); exit(EXIT_FAILURE); } while (0)

#define CRIT  0
#define ERR   1
#define WARN  2
#define INFO  3
#define DEBUG 4

#define DATA_PATH "/home/jpe/git/hub/s/stic2012/input/data/"

/*
#ifdef __DEBUG__
  #undef __DEBUG__
#endif
*/

#define __DEBUG__ 1
#ifdef __DEBUG__
#define debug(level, format, ...) {                                                                                                 \
    				    if ( (level) <= verbose_level )                                                                 \
    				        fprintf(stdout, "[+] " __FILE__ ":%s:%d " format "\n", __func__, __LINE__, ##__VA_ARGS__ ); \
                                  }
#else
#define debug(level, format, ...) {}
#endif
