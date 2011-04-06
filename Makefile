CC := gcc
CFLAGS := -Wall -O3
EXTRA_CPPFLAGS := -DUDP_FLIP

LUAC := luac
LUACFLAGS := -s

MANIFEST := nattcp$(EXEEXT) udp-climber

all : $(MANIFEST)

win32:
	make CC="$(CC)" \
	     CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" LDFLAGS="$(LDFLAGS)" \
	     EXEEXT=".exe" all
win64:
	make CC="$(CC)" \
	     CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" LDFLAGS="$(LDFLAGS)" \
	     EXEEXT=".exe" all

nattcp$(EXEEXT) : nattcp.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(EXTRA_CPPFLAGS) $(LDFLAGS) -o $@ $<

udp-climber : udp-climber.lua
	echo "#!/usr/bin/lua" >$@
	$(LUAC) $(LUACFLAGS) -o - $< >>$@
	chmod +x $@

clean:
	rm -f *.o $(MANIFEST)
