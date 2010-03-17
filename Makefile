# rpg makefile
.POSIX:

# Default make target
all::

# XXX include isn't POSIX but I don't feel like dealing with it right now.
# we'll move to a separate Makefile.in eventually.
include config.mk

NAME = rpg
TARNAME = $(NAME)
SHELL = /bin/sh

# srcdir      = .
# prefix      = /usr/local
# exec_prefix = ${prefix}
# bindir      = ${exec_prefix}/bin
# libexecdir  = ${exec_prefix}/libexec
# datarootdir = ${prefix}/share
# datadir     = ${datarootdir}
# mandir      = ${datarootdir}/man
# docdir      = $(datadir)/doc/$(TARNAME)

# ---- END OF CONFIGURATION ----

all:: build

SOURCES = \
	rpg-sh-setup.sh rpg.sh rpg-config.sh rpg-fetch.sh rpg-install.sh \
	rpg-version-test.sh rpg-uninstall.sh rpg-build.sh rpg-env.sh rpg-sync.sh \
	rpg-resolve.sh rpg-upgrade.sh rpg-steal.sh rpg-fsck.sh rpg-outdated.sh \
	rpg-package-register.sh rpg-package-install.sh rpg-solve.sh rpg-unpack.sh \
	rpg-package-spec.rb rpg-parse-index.rb rpg-shit-list.sh rpg-prepare.sh \
	rpg-help.sh rpg-package-index.sh rpg-list.sh

DOCHTML = \
	rpg-sh-setup.html rpg.html rpg-fetch.html rpg-version-test.html \
	rpg-sync.html rpg-upgrade.html rpg-outdated.html \
	rpg-package-install.html rpg-package-spec.html rpg-parse-index.html \
	rpg-list.html

PROGRAMPROGRAMS = \
	rpg-config rpg-fetch rpg-install rpg-version-test rpg-uninstall rpg-build \
	rpg-env rpg-sync rpg-resolve rpg-upgrade rpg-steal rpg-fsck rpg-status \
	rpg-outdated rpg-package-list rpg-package-register rpg-package-install \
	rpg-solve rpg-unpack rpg-package-spec rpg-parse-index rpg-shit-list \
	rpg-prepare rpg-complete rpg-help rpg-package-index rpg-list

USERPROGRAMS = rpg rpg-sh-setup

PROGRAMS = $(USERPROGRAMS) $(PROGRAMPROGRAMS)

.SUFFIXES: .sh .rb .html

.sh:
	printf "%13s  %-30s" "[SH]" "$@"
	$(SHELL) -n $<
	rm -f $@
	$(RUBY) ./munge.rb __RPGCONFIG__ config.sh <$< >$@+
	chmod a-w+x $@+
	mv $@+ $@
	printf "       OK\n"

.sh.html:
	printf "%13s  %-30s" "[SHOCCO]" "$@"
	shocco $< > $@
	printf "       OK\n"

.rb:
	printf "%13s  %-30s" "[RUBY]" "$@"
	ruby -c $< >/dev/null
	rm -f $@
	cp $< $@
	chmod a-w+x $@
	printf "       OK\n"

.rb.html:
	printf "%13s  %-30s" "[ROCCO]" "$@"
	rocco $< >/dev/null
	printf "       OK\n"

rpg-sh-setup: config.sh munge.rb
rpg: config.sh munge.rb

build: $(PROGRAMS)

auto:
	while true; do $(MAKE) ; sleep 1; done

doc: $(DOCHTML)

install:
	mkdir -p "$(bindir)" || true
	for f in $(USERPROGRAMS); do \
		echo "$(INSTALL_PROGRAM) $$f $(bindir)"; \
		$(INSTALL_PROGRAM) $$f "$(bindir)"; \
	done
	mkdir -p "$(libexecdir)" || true
	for f in $(PROGRAMPROGRAMS); do \
		echo "$(INSTALL_PROGRAM) $$f $(libexecdir)"; \
		$(INSTALL_PROGRAM) $$f "$(libexecdir)"; \
	done

uninstall:
	for f in $(USERPROGRAMS); do \
		test -e "$(bindir)/$$f" || continue; \
		echo "rm -f $(bindir)/$$f"; \
		rm "$(bindir)/$$f"; \
	done
	for f in $(PROGRAMPROGRAMS) rpg-update; do \
		test -e "$(libexecdir)/$$f" || continue; \
		echo "rm -f $(libexecdir)/$$f"; \
		rm "$(libexecdir)/$$f"; \
	done

install-local:
	./configure --prefix=/usr/local
	sleep 1
	make
	make install
	./configure --development

clean:
	rm -vf $(PROGRAMS) $(DOCHTML)

.SILENT:

.PHONY: install uninstall clean
