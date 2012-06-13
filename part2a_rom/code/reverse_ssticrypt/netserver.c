#include "server.h"
#include "utils.h"
#include <stdint.h>
#include <strings.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 31337

extern uint8_t *from_client;


void error(const char *msg)
{
    perror(msg);
    exit(1);
}

void loop(void) {
    struct usb_req ureq;
    uint8_t req;
    uint16_t value, index, size;
    int yes = 1;

    uint8_t buf[255];
    int sockfd, newsockfd, portno;
    socklen_t clilen;
    struct sockaddr_in serv_addr, cli_addr;

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) 
	error("ERROR opening socket");
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));

    bzero((char *) &serv_addr, sizeof(serv_addr));
    portno = PORT;
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(portno);
    if (bind(sockfd, (struct sockaddr *) &serv_addr,
		sizeof(serv_addr)) < 0) 
	error("ERROR on binding");
    listen(sockfd,5);
    clilen = sizeof(cli_addr);


    for (;;) {
	newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, 
		&clilen);
	if (newsockfd < 0) 
	    error("ERROR on accept");

	while (read(newsockfd, buf, 7) == 7) {
	    req = buf[0];
	    value = buf[1] | (buf[2] << 8);
	    index = buf[3] | (buf[4] << 8);
	    size  = buf[5] | (buf[6] << 8);
	    //printf("request = 0x%x, value = 0x%x, index = 0x%x, size = 0x%x\n", req, value, index, size);
	    ureq.request = 1;
	    ureq.request = req;
	    ureq.value = value;
	    ureq.index = index;
	    ureq.length = size;

	    switch(req) {
		case 0x51:
		    //printf("read request\n");
		    if (read(newsockfd, buf, size) != size)
		    	error("read");
		    memcpy(from_client, buf, size);
		    handle_usb_vendor_int(&ureq);
		    break;
		case 0x56:
		    //printf("send request\n");
		    handle_usb_vendor_int(&ureq);
		    memcpy(buf, from_client, size);
		    if (write(newsockfd, buf, size) != size)
		    	error("write");
		    break;
		default:
		    printf("invalid request: %x\n", req);
		    exit(EXIT_FAILURE);
	    }
	}

	close(newsockfd);
    }
}

int main(int argc, char **argv) {
    do_server_init();
    loop();
    exit(EXIT_SUCCESS);
}
