VERSION := 7.1.4

CC := gcc
CFLAGS := -Wall -O

override CPPFLAGS += -DUDP_FLIP -DSSL_AUTH
override LDFLAGS += -lpolarssl

LUAC := luac
LUACFLAGS := -s

# Cygwin
#CFLAGS += -m32 -march=i486
#EXEEXT := .exe

MANIFEST := nattcp$(EXEEXT) udp-climber
DIST := Makefile nattcp.c polarssl.c udp-climber.lua nuttcp.8 LICENSE \
	xinetd.d/nattcp xinetd.d/nattcp4 xinetd.d/nattcp6

all : $(MANIFEST)

nattcp$(EXEEXT) : nattcp.o polarssl.o
	$(CC) $(LDFLAGS) -o $@ $^

udp-climber : udp-climber.lua
	echo "#!/usr/bin/lua" >$@
	$(LUAC) $(LUACFLAGS) -o - $< >>$@
	chmod +x $@

install : $(MANIFEST)
	mkdir -p $(DESTDIR)/usr/bin
	install -m 0755 nattcp $(DESTDIR)/usr/bin/
	install -m 0755 udp-climber $(DESTDIR)/usr/bin/

clean:
	rm -f *.o $(MANIFEST)

# Win32 binary release
release : $(MANIFEST) cyggcc_s-1.dll cygwin1.dll lua.exe lua5.1.dll
	rm -f nattcp-$(VERSION)-win32.zip
	zip nattcp-$(VERSION)-win32.zip $^

# automake-style source distro
dist : $(DIST)
	tar czf nattcp-$(VERSION).tar.gz --xform "s,^,nattcp-$(VERSION)/,S" $^
