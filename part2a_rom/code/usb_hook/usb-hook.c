#include <usb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <ctype.h>

#define HOSTNAME "10.0.0.11"

int sockfd;

struct usb_device device;
struct usb_bus bus;
usb_dev_handle *usb_handle;

int usb_close(usb_dev_handle *dev) {
    printf("usb_close() called\n");
    close(sockfd);
    return 0;
}

struct usb_bus *usb_get_busses(void) {
    printf("usb_get_busses() called\n");
    return &bus;
}

usb_dev_handle *usb_open(struct usb_device *device) {
    struct sockaddr_in serv_addr;
    struct hostent *server;
    char *target;

    printf("usb_open() called\n");
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
	perror("socket:");
	exit(EXIT_FAILURE);
    }
    target = getenv("TARGET");
    if (!target)
        target = HOSTNAME;
    server = gethostbyname(target);
    if (server == NULL) {
	printf("resolution failed\n");
	exit(EXIT_FAILURE);
    }

    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, 
	    (char *)&serv_addr.sin_addr.s_addr,
	    server->h_length);
    serv_addr.sin_port = htons(31337);

    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) {
	perror("connect:");
	exit(EXIT_FAILURE);
    }
    usb_handle = (usb_dev_handle *) 1;
    return usb_handle;
}

void usb_init(void) {
    printf("usb_init() called\n");
    device.descriptor.idVendor = 0x4c1;
    device.descriptor.idProduct = 0x9d;
    bus.devices = &device;
}

int usb_find_busses(void) {
    printf("usb_find_busses() called\n");
    return 0;
}

int usb_find_devices(void) {
    printf("usb_find_devices() called\n");
    return 0;
}

void print_bytes(char *buf, int size) {
    int i;
    for (i = 0; i < size; i ++) {
	printf("%02x ", buf[i] & 0xff);
    }
    printf("\n");
}

int usb_control_msg(usb_dev_handle *dev, int requesttype, int request, int value, int index, char *bytes, int size, int timeout) {
	char buf[24];
	int ret;

	printf("usb_control_msg(%p, %x, %x, %x, %x, %p, %x, %x): ",
			dev, requesttype, request, value, index, bytes, size, timeout);

	buf[1] = value & 0xff;
	buf[2] = (value >> 8) & 0xff;
	buf[3] = index & 0xff;
	buf[4] = (index >> 8) & 0xff;
	buf[5] = size & 0xff;
	buf[6] = (size >> 8) & 0xff;

	switch(request) {
		case 0x51:
			print_bytes(bytes, size);
			buf[0] = 0x51;
			memcpy(buf + 7, bytes, size);
			write(sockfd, buf, 7 + size);
			ret = 0;
			break;
		case 0x56:
			buf[0] = 0x56;
			write(sockfd, buf, 7);
			ret = read(sockfd, bytes, size);
			print_bytes(bytes, ret);
			break;
		default:
			printf("unhandled request: 0x%x\n", request);

	};

	return ret;
}
