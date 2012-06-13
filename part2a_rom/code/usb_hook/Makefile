CC=gcc
CFLAGS=-W -Wall -Wno-unused

%.so: %.c
	$(CC) $(CFLAGS) -shared -fPIC -o $@ $< -ldl

default: usb-hook.so

clean:
	rm -f usb-hook.so
