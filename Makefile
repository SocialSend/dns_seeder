CXXFLAGS = -O3 -g0
LDFLAGS = $(CXXFLAGS)

dnsseed: dns.o bitcoin.o netbase.o protocol.o db.o main.o util.o
	g++ -pthread $(LDFLAGS) -o dnsseed dns.o bitcoin.o netbase.o protocol.o db.o main.o util.o -lcrypto

%.o: %.cpp bitcoin.h netbase.h protocol.h db.h serialize.h uint256.h util.h
	g++ -pthread $(CXXFLAGS) -Wno-invalid-offsetof -c -o $@ $<

dns.o: dns.c
	gcc -pthread -std=c99 $(CXXFLAGS) dns.c -c -o dns.o

%.o: %.cpp

.PHONY: clean
clean:
	rm -f dnsseed *.o

PREFIX = /usr/local

.PHONY: install
install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p /usr/local/share/dnsseed
	chmod 766 -R /usr/local/share/dnsseed
	chown dnsseed:dnsseed -R /usr/local/share/dnsseed
	cp dnsseed $(DESTDIR)$(PREFIX)/bin
	iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-port 5353

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dnsseed
	rm -R /usr/local/share/dnsseed
	iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-port 5353
	
