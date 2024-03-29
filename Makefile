# danectl - DNSSEC DANE implementation manager
# https://raf.org/danectl
# https://github.com/raforg/danectl
# https://codeberg.org/raforg/danectl
#
# Copyright (C) 2021-2023 raf <raf@raf.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <https://www.gnu.org/licenses/>.
#

# 20230718 raf <raf@raf.org>

DESTDIR :=
PREFIX := $(DESTDIR)/usr/local

APP_INSDIR := $(PREFIX)/bin
MAN_INSDIR := $(PREFIX)/share/man

APP_MANSECT := 1
APP_MANDIR := $(MAN_INSDIR)/man$(APP_MANSECT)
APP_MANSECTNAME := User Commands

DANECTL_NAME=danectl
DANECTL_VERSION=0.8.4
DANECTL_DATE=20230718
DANECTL_ID=$(DANECTL_NAME)-$(DANECTL_VERSION)
DANECTL_DIST=$(DANECTL_ID).tar.gz
DANECTL_MANFILE=$(DANECTL_NAME).$(APP_MANSECT)
DANECTL_HTMLFILE=$(DANECTL_NAME).$(APP_MANSECT).html

DANECTL_ZONEFILE_NAME=danectl-zonefile
DANECTL_ZONEFILE_MANFILE=$(DANECTL_ZONEFILE_NAME).$(APP_MANSECT)
DANECTL_ZONEFILE_HTMLFILE=$(DANECTL_ZONEFILE_NAME).$(APP_MANSECT).html

DANECTL_NSUPDATE_NAME=danectl-nsupdate
DANECTL_NSUPDATE_MANFILE=$(DANECTL_NSUPDATE_NAME).$(APP_MANSECT)
DANECTL_NSUPDATE_HTMLFILE=$(DANECTL_NSUPDATE_NAME).$(APP_MANSECT).html

help:
	@echo "This Makefile supports the following targets:"; \
	echo; \
	echo "  help          - Show this list of targets (default)"; \
	echo "  install       - install-bin + install-man"; \
	echo "  install-bin   - Install danectl, danectl-zonefile, and danectl-nsupdate"; \
	echo "  install-man   - Install the danectl(1) manual entry"; \
	echo "  uninstall     - uninstall-bin + uninstall-man"; \
	echo "  uninstall-bin - Uninstall danectl, danectl-zonefile, and danectl-nsupdate"; \
	echo "  uninstall-man - Uninstall the danectl(1) manual entry"; \
	echo "  man           - Generate the manual entries using pod2man"; \
	echo "  html          - Generate HTML versions of the manual entries using pod2html"; \
	echo "  clean         - Delete any generated manual entries"; \
	echo "  test          - Run the tests"; \
	echo "  dist          - Create the distribution tarball"; \
	echo

install: install-bin install-man

install-bin:
	mkdir -p $(APP_INSDIR)
	install -m 755 $(DANECTL_NAME) $(DANECTL_ZONEFILE_NAME) $(DANECTL_NSUPDATE_NAME) $(APP_INSDIR)
	@[ ! -x /usr/xpg4/bin/sh ] || sed 's,^#!/bin/sh$$,#!/usr/xpg4/bin/sh,' < $(DANECTL_NAME) > $(APP_INSDIR)/$(DANECTL_NAME)

install-man: man
	mkdir -p $(APP_MANDIR)
	install -m 644 $(DANECTL_MANFILE) $(APP_MANDIR)
	install -m 644 $(DANECTL_NSUPDATE_MANFILE) $(APP_MANDIR)
	install -m 644 $(DANECTL_ZONEFILE_MANFILE) $(APP_MANDIR)

uninstall: uninstall-bin uninstall-man

uninstall-bin:
	[ ! -f $(APP_INSDIR)/$(DANECTL_NAME) ] || rm -r $(APP_INSDIR)/$(DANECTL_NAME)
	[ ! -f $(APP_INSDIR)/$(DANECTL_ZONEFILE_NAME) ] || rm -r $(APP_INSDIR)/$(DANECTL_ZONEFILE_NAME)
	[ ! -f $(APP_INSDIR)/$(DANECTL_NSUPDATE_NAME) ] || rm -r $(APP_INSDIR)/$(DANECTL_NSUPDATE_NAME)

uninstall-man:
	[ ! -f $(APP_MANDIR)/$(DANECTL_MANFILE) ] || rm -r $(APP_MANDIR)/$(DANECTL_MANFILE)
	[ ! -f $(APP_MANDIR)/$(DANECTL_NSUPDATE_MANFILE) ] || rm -r $(APP_MANDIR)/$(DANECTL_NSUPDATE_MANFILE)
	[ ! -f $(APP_MANDIR)/$(DANECTL_ZONEFILE_MANFILE) ] || rm -r $(APP_MANDIR)/$(DANECTL_ZONEFILE_MANFILE)

man: $(DANECTL_MANFILE) $(DANECTL_NSUPDATE_MANFILE) $(DANECTL_ZONEFILE_MANFILE)

html: $(DANECTL_HTMLFILE) $(DANECTL_NSUPDATE_HTMLFILE) $(DANECTL_ZONEFILE_HTMLFILE)

$(DANECTL_NAME).$(APP_MANSECT): $(DANECTL_NAME)
	./$< help | perl -pe 's/^([A-Z ]+)$$/=head1 $$1/' | pod2man --section='$(APP_MANSECT)' --center='$(APP_MANSECTNAME)' --name='$(shell echo $(DANECTL_NAME) | tr a-z A-Z)' --release='$(DANECTL_ID)' --date='$(DANECTL_DATE)' --quotes=none > $@

$(DANECTL_NAME).$(APP_MANSECT).html: $(DANECTL_NAME)
	./$< help | perl -pe 's/^([A-Z ]+)$$/=head1 $$1/' | pod2html --noindex --title='$(DANECTL_NAME)($(APP_MANSECT))' > $@ 2>/dev/null
	rm -r pod2htm*.tmp

%: %.pod
	pod2man --section='$(APP_MANSECT)' --center='$(APP_MANSECTNAME)' --name='$(shell echo $@ | tr a-z A-Z | sed "s/\.$(APP_MANSECT)$$//")' --release='$(DANECTL_ID)' --date='$(DANECTL_DATE)' --quotes=none $< > $@

%.html: %.pod
	pod2html --noindex --title='$<($(APP_MANSECT))' $< > $@ 2>/dev/null
	rm -r pod2htm*.tmp

clean:
	rm -f *.$(APP_MANSECT) *.$(APP_MANSECT).html

test:
	./runtests

dist: clean man
	@set -e; \
	up="`pwd`/.."; \
	src=`basename \`pwd\``; \
	dst=$(DANECTL_ID); \
	cd ..; \
	[ "$$src" != "$$dst" -a ! -d "$$dst" ] && ln -s $$src $$dst; \
	tar chzf $$up/$(DANECTL_DIST) --exclude='.git*' $$dst; \
	[ -h "$$dst" ] && rm -f $$dst; \
	tar tzfv $$up/$(DANECTL_DIST); \
	ls -l $$up/$(DANECTL_DIST)

# vi:set ts=4 sw=4:
