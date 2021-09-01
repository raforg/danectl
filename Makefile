#
# danectl - http://raf.org/danectl/
#
# Copyright (C) 2021 raf <raf@raf.org>
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

# 20210831 raf <raf@raf.org>

DESTDIR :=
PREFIX := $(DESTDIR)/usr/local

APP_INSDIR := $(PREFIX)/bin
MAN_INSDIR := $(PREFIX)/share/man

APP_MANSECT := 1
APP_MANDIR := $(MAN_INSDIR)/man$(APP_MANSECT)
APP_MANSECTNAME := User Commands

DANECTL_NAME=danectl
DANECTL_VERSION=0.4.1
DANECTL_DATE=20210901
DANECTL_ID=$(DANECTL_NAME)-$(DANECTL_VERSION)
DANECTL_DIST=$(DANECTL_ID).tar.gz
DANECTL_MANFILE=$(DANECTL_NAME).$(APP_MANSECT)
DANECTL_HTMLFILE=$(DANECTL_NAME).$(APP_MANSECT).html

install: install-bin install-man

dist: clean $(DANECTL_MANFILE)
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

install-bin:
	mkdir -p $(APP_INSDIR)
	install -m 755 $(DANECTL_NAME) $(APP_INSDIR)

install-man: $(DANECTL_MANFILE)
	mkdir -p $(APP_MANDIR)
	install -m 644 $(DANECTL_MANFILE) $(APP_MANDIR)

uninstall: uninstall-bin uninstall-man

uninstall-bin:
	rm -r $(APP_INSDIR)/$(DANECTL_NAME)

uninstall-man:
	rm -r $(APP_MANDIR)/$(DANECTL_MANFILE)

%.$(APP_MANSECT): %
	./$< help | perl -pe 's/^([A-Z ]+)$$/=head1 $$1/' | pod2man --section='$(APP_MANSECT)' --center='$(APP_MANSECTNAME)' --name='$(shell echo $(DANECTL_NAME) | tr a-z A-Z)' --release='$(DANECTL_ID)' --date='$(DANECTL_DATE)' --quotes=none > $@

%.$(APP_MANSECT).html: %
	./$< help | perl -pe 's/^([A-Z ]+)$$/=head1 $$1/' | pod2html --noindex --title='$(DANECTL_NAME)($(APP_MANSECT))' > $@ 2>/dev/null
	rm -r pod2htm*.tmp

clean:
	rm -f $(DANECTL_NAME).$(APP_MANSECT) $(DANECTL_NAME).$(APP_MANSECT).html

