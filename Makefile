# pgem makefile
.POSIX:

# Default make target
all::

NAME = pgem
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

# Change this to `install-standalone' if you want a single pgem command. By
# default, all pgem- commands are installed.
#
# NOTE: the standalone stuff doesn't work yet.
INSTALLMETHOD = install-multi

# ---- END OF CONFIGURATION ----

all:: build

SOURCES = pgem-sh-setup.sh \
		  pgem.sh \
		  pgem-config.sh \
		  pgem-deps.sh \
		  pgem-fetch.sh \
		  pgem-install.sh \
		  pgem-list.sh \
		  pgem-version-test.sh \
		  pgem-uninstall.sh \
		  pgem-build.sh \
		  pgem-env.sh \
		  pgem-update.sh \
		  pgem-resolve.sh

PROGRAMS = pgem-sh-setup \
		   pgem \
		   pgem-config \
		   pgem-deps \
		   pgem-fetch \
		   pgem-install \
		   pgem-list \
		   pgem-version-test \
		   pgem-uninstall \
		   pgem-build \
		   pgem-env \
		   pgem-update \
		   pgem-resolve

STANDALONE = $(NAME)

CLEAN = $(STANDALONE) syntax

.sh:
	$(SHELL) -n $<
	cp $< $@
	chmod +x $@

build: $(PROGRAMS) $(STANDALONE)
	echo "  DONE  $(NAME) built successfully. Ready to \`make install'."

pgem-sa:
	echo " BUILD  $(STANDALONE)"
	$(SHELL) shc -m pgem $(SOURCES) > $(STANDALONE) || { \
		rm -f $(STANDALONE); \
		false; \
	}; \
	chmod 0755 $(STANDALONE)

install: $(INSTALLMETHOD)

install-standalone:
	mkdir -p $(bindir)
	cp pgem-sa $(bindir)/pgem
	chmod 0755 $(bindir)/pgem

install-multi:
	mkdir -p $(bindir)
	for f in $(SOURCES); do \
		echo "installing: $$f"; \
		cp $$f "$(bindir)/$$f" && \
		chmod 0755 "$(bindir)/$$f"; \
	done

uninstall:
	for f in $(SOURCES); do \
		test -e "$(bindir)/$$f" || continue; \
		echo "uninstalling: $$f"; \
		rm -f "$(bindir)/$$f"; \
	done

clean:
	rm -f $(CLEAN)

.SILENT:

.SUFFIXES: .sh
