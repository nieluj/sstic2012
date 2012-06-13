CC=gcc
CFLAGS=-O2 -W -Wall -Wno-unused -std=c99 
#LDFLAGS=

UNIT_TESTS = $(wildcard test_*_*.c)
UNIT_TESTS_OBJ = $(UNIT_TESTS:.c=.o)

#tests_server: tests.o server.o utils.o $(UNIT_TESTS_OBJ)
#	$(CC) -o $@ $^ $(CFLAGS)

unit_tests: unit_tests.o server.o utils.o
	$(CC) -o $@ $^ $(CFLAGS)

test_key: test_key.o client.o server.o utils.o
	$(CC) -o $@ $^ $(CFLAGS)

netserver: netserver.o server.o utils.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o unit_tests test_key netserver

default: test_key
