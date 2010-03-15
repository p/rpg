# rpg makefile
.POSIX:

# Default make target
all::

NAME = rpg
TARNAME = $(NAME)
SHELL = /bin/sh

srcdir      = .
prefix      = /usr/local
exec_prefix = ${prefix}
bindir      = ${exec_prefix}/bin
libexecdir  = ${exec_prefix}/libexec
datarootdir = ${prefix}/share
datadir     = ${datarootdir}
mandir      = ${datarootdir}/man
docdir      = $(datadir)/doc/$(TARNAME)

# Change this to `install-standalone' if you want a single rpg command. By
# default, all rpg- commands are installed.
#
# NOTE: the standalone stuff doesn't work yet.
INSTALLMETHOD = install-multi

# ---- END OF CONFIGURATION ----

all:: build

SOURCES = \
	rpg-sh-setup.sh rpg.sh rpg-config.sh rpg-fetch.sh \
	rpg-install.sh rpg-list.sh rpg-version-test.sh rpg-uninstall.sh \
	rpg-build.sh rpg-env.sh rpg-update.sh rpg-resolve.sh rpg-upgrade.sh \
	rpg-steal.sh rpg-fsck.sh rpg-status.sh rpg-outdated.sh \
	rpg-package-register.sh rpg-package-install.sh rpg-solve.sh rpg-unpack.sh \
	rpg-package-spec.rb rpg-parse-index.rb

PROGRAMS = \
	rpg-sh-setup rpg rpg-config rpg-fetch \
	rpg-install rpg-list rpg-version-test rpg-uninstall \
	rpg-build rpg-env rpg-update rpg-resolve rpg-upgrade \
	rpg-steal rpg-fsck rpg-status rpg-outdated rpg-parse-package-list \
	rpg-package-register rpg-package-install rpg-solve rpg-unpack \
	rpg-package-spec rpg-parse-index

DOCHTML = \
	rpg-sh-setup.html rpg.html rpg-config.html rpg-fetch.html \
	rpg-install.html rpg-list.html rpg-version-test.html rpg-uninstall.html \
	rpg-build.html rpg-env.html rpg-update.html rpg-resolve.html \
	rpg-upgrade.html rpg-steal.html rpg-fsck.html rpg-status.html \
	rpg-outdated.html rpg-package-register.html rpg-package-install.html \
	rpg-solve.html rpg-package-spec.html rpg-parse-index.html

STANDALONE = $(NAME)-sa

.SUFFIXES: .sh .rb .html

.sh:
	printf "%13s  %-30s" "[SH]" "$@"
	$(SHELL) -n $<
	rm -f $@
	cp $< $@
	chmod a-w+x $@
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
	rocco $<
	printf "       OK\n"

build: $(PROGRAMS)

auto:
	while true; do $(MAKE) ; sleep 1; done

doc: $(DOCHTML)

$(STANDALONE): $(SOURCES) shc
	echo "   SHC  $(STANDALONE)"
	$(SHELL) shc -m rpg $(SOURCES) > $(STANDALONE) || { \
		rm -f $(STANDALONE); \
		false; \
	}; \
	chmod 0755 $(STANDALONE)

install: $(INSTALLMETHOD)

install-standalone:
	mkdir -p $(bindir)
	cp rpg-sa $(bindir)/rpg
	chmod 0755 $(bindir)/rpg

install-multi:
	mkdir -p $(bindir)
	for f in $(PROGRAMS); do \
		echo "installing: $$f"; \
		cp $$f "$(bindir)/$$f" && \
		chmod 0755 "$(bindir)/$$f"; \
	done

uninstall:
	for f in $(PROGRAMS); do \
		test -e "$(bindir)/$$f" || continue; \
		echo "uninstalling: $$f"; \
		rm -f "$(bindir)/$$f"; \
	done

clean:
	echo $(STANDALONE) $(PROGRAMS) $(DOCHTML) | xargs -tn 1 rm -f

.SILENT:
