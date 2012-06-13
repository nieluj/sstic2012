#include "server.h"
#include "client.h"
#include "utils.h"
#include <stdio.h>
#include <stdlib.h>

void test_key(char *k) {
    do_client_init();
    do_server_init();

    check_key(k, 1);
}

int main(int argc, char **argv) {
    verbose_level = INFO;
    test_key("e5df94e3f63d8937");
    //test_key("a1a2a3a4a5a6a7a8");
    exit(EXIT_SUCCESS);
}
