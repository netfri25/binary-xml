CFLAGS += -std=c2x -Wall -Wextra -pedantic
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
CC     ?= gcc

all: encode decode

encode: encode.c Makefile
	$(CC) -O3 $(CFLAGS) -o $@ $< $(LDFLAGS)

decode: decode.c Makefile
	$(CC) -O3 $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -f encode decode

.PHONY: all clean
