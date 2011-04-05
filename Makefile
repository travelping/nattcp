CC ?= gcc

CFLAGS ?= -Wall -g -O0
CPPFLAGS += -DUDP_FLIP

all : nattcp

nattcp : nattcp.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $@ $<

clean:
	rm -f nattcp *.o
