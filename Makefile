APP = nuttcp-6.1.2
#EXTRAVERSION=-pre1
CC = gcc -Wall
#OPT = -g -O0
OPT = -O3
CFLAGS = $(OPT) $(NOIPV6)
LIBS = 
ifneq ($(NOIPV6),)
APPEXTV6=-noipv6
endif
APPEXT = $(APPEXTV6)

CFLAGS.MISSING = -Imissing -DHAVE_CONFIG_H
OBJS.GETADD = getaddrinfo.o
OBJS.INETFUN = inet_ntop.o inet_pton.o inet_aton.o 

TAR = tar

all: $(APP)$(EXTRAVERSION)$(APPEXT)

uniosx:
	$(MAKE) OPT="-O3 -arch i386 -arch ppc"

sgicc32:
	$(MAKE) CC="cc -n32" OPT="-O -OPT:Olimit=0"

sgicc:
	$(MAKE) CC=cc OPT="-O -OPT:Olimit=0"

sol28:
	$(MAKE) LIBS="-lsocket -lnsl"

sol28cc:
	$(MAKE) CC=cc OPT=-O LIBS="-lsocket -lnsl"

sol26:
	$(MAKE) CFLAGS="$(CFLAGS) $(CFLAGS.MISSING)" LIBS="$(OBJS.GETADD) $(OBJS.INETFUN) -lsocket -lnsl"

sol26cc:
	$(MAKE) CC=cc OPT=-O CFLAGS="-O $(NOIPV6) $(CFLAGS.MISSING)" LIBS="$(OBJS.GETADD) $(OBJS.INETFUN) -lsocket -lnsl"

cyg:
	$(MAKE) APPEXT=".exe"

oldcyg:
	$(MAKE) CFLAGS="$(CFLAGS) $(CFLAGS.MISSING)" LIBS="$(OBJS.GETADD) $(OBJS.INETFUN)" APPEXT=".exe"

win32:
	$(MAKE) LIBS="$(OBJS.INETFUN) -Lwin32 -llibc.a -Bstatic" APPEXT=".exe"

icc:
	$(MAKE) CC=icc OPT=-O2
#	$(MAKE) CC=icc OPT="-w -O3 -parallel -unroll -align -xM -vec_report -par_report2"

$(APP)$(EXTRAVERSION)$(APPEXT): $(APP)$(EXTRAVERSION).c $(LIBS)
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)
inet_ntop.o: missing/inet_ntop.c missing/config.h
	$(CC) $(CFLAGS.MISSING) -o $@ -c $<
inet_pton.o: missing/inet_pton.c missing/config.h
	$(CC) $(CFLAGS.MISSING) -o $@ -c $<
inet_aton.o: missing/inet_aton.c missing/config.h
	$(CC) $(CFLAGS.MISSING) -o $@ -c $<
getaddrinfo.o: missing/getaddrinfo.c missing/config.h
	$(CC) $(CFLAGS.MISSING) -o $@ -c $<

clean:
	rm  -f $(APP)$(EXTRAVERSION)$(APPEXT) $(APP)$(EXTRAVERSION).o $(OBJS.GETADD) $(OBJS.INETFUN)

tar:
	(cd ..; $(TAR) cfj $(APP)$(EXTRAVERSION).tar.bz2 --exclude $(APP)/bin --exclude $(APP)/cygwin/*.bz2 --exclude $(APP)/rpm $(APP)$(EXTRAVERSION)$(APPEXT))
	(cd ..; $(TAR) cfj $(APP)$(EXTRAVERSION).rpm.tar.bz2 --exclude $(APP)/bin --exclude $(APP)/cygwin  --exclude $(APP)/missing --exclude $(APP)/rpm $(APP)$(EXTRAVERSION)$(APPEXT))
