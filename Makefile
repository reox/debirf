#!/usr/bin/make -f

# Makefile for debirf

# (c) 2008-2011 Jameson Graef Rollins <jrollins@finestructure.net>
#               Daniel Kahn Gillmor <dkg@fifthhorseman.net>
# Licensed under GPL v3 or later

VERSION := `head -n1 debian/changelog | sed 's/.*(\([^-]*\).*/\1/'`

PREFIX ?= /usr
MANPREFIX ?= $(PREFIX)/share/man

PROFILES = minimal rescue xkiosk

PROFILE_TARBALLS = $(foreach profile,$(PROFILES),doc/example-profiles/$(profile).tgz)
PROFILE_MODULES = $(foreach profile,$(PROFILES),doc/example-profiles/$(profile)/modules)

default: $(PROFILE_TARBALLS)

doc/example-profiles/%/modules: doc/example-profiles/%.modules
	mkdir -p "$@"
	for m in $(shell cat $<); do ln -s /usr/share/debirf/modules/$$m $@/; done

doc/example-profiles/%.tgz: doc/example-profiles/% doc/example-profiles/%/modules
	(cd doc/example-profiles && tar c --exclude='*~' $(notdir $<)) | gzip -9 -n > "$@"

install: installman profiles
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/share/doc/debirf/example-profiles
	mkdir -p $(DESTDIR)$(PREFIX)/share/debirf/modules
	install src/debirf $(DESTDIR)$(PREFIX)/bin
	install src/common $(DESTDIR)$(PREFIX)/share/debirf
	install --mode=644 src/devices.tar.gz $(DESTDIR)$(PREFIX)/share/debirf
	install src/modules/* $(DESTDIR)$(PREFIX)/share/debirf/modules
	install doc/README $(DESTDIR)$(PREFIX)/share/doc/debirf
	install doc/autobuilder $(DESTDIR)$(PREFIX)/share/doc/debirf
	install doc/example-profiles/*.tgz $(DESTDIR)$(PREFIX)/share/doc/debirf/example-profiles

installman:
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	gzip -n man/*/*
	install man/man1/* $(DESTDIR)$(MANPREFIX)/man1
	gzip -d man/*/*

clean:
	rm -f $(PROFILE_TARBALLS)
	rm -rf $(PROFILE_MODULES)

.PHONY: default install installman profiles clean
