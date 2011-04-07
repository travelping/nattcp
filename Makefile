VERSION := 7.1.4

CC := gcc
CFLAGS := -Wall -O3
CPPFLAGS += -DUDP_FLIP

LUAC := luac
LUACFLAGS := -s

# Cygwin
#CFLAGS += -m32 -march=i486
#EXEEXT := .exe

MANIFEST := nattcp$(EXEEXT) udp-climber

all : $(MANIFEST)

nattcp$(EXEEXT) : nattcp.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $@ $<

udp-climber : udp-climber.lua
	echo "#!/usr/bin/lua" >$@
	$(LUAC) $(LUACFLAGS) -o - $< >>$@
	chmod +x $@

clean:
	rm -f *.o $(MANIFEST)

# Win32 binary release
release : $(MANIFEST) cyggcc_s-1.dll cygwin1.dll lua.exe lua5.1.dll
	rm -f nattcp-$(VERSION)-win32.zip
	zip nattcp-$(VERSION)-win32.zip $^

# automake-style source distro
dist : Makefile nattcp.c udp-climber.lua nuttcp.8 LICENSE
	tar czf nattcp-$(VERSION).tar.gz --xform "s,^,nattcp-$(VERSION)/,S" $^
