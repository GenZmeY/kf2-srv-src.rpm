NAME          := kf2-srv

RPMBUILDDIR   := $$HOME/rpmbuild
ACTIVEDIR     := $(shell readlink -e $$HOME/rpmbuild)
WORKDIR       := $(shell readlink -e .)

BUILDDIR      := $(WORKDIR)/BUILD
BUILDROOTDIR  := $(WORKDIR)/BUILDROOT
RPMSDIR       := $(WORKDIR)/RPMS
SOURCESDIR    := $(WORKDIR)/SOURCES
SPECSDIR      := $(WORKDIR)/SPECS
SRPMSDIR      := $(WORKDIR)/SRPMS

SPEC          := $(SPECSDIR)/$(NAME).spec

.PHONY: all prep rpm srpm activate active check-activate clean-tmp clean-pkg clean builddep test

all: check-activate prep
	rpmbuild -ba $(SPEC)
	$(MAKE) clean-tmp

builddep:
	dnf builddep -y $(SPEC)

prep: clean-tmp
	spectool -g -R $(SPEC)

rpm: check-activate prep
	rpmbuild -bb $(SPEC)
	$(MAKE) clean-tmp

srpm: check-activate prep
	rpmbuild -bs $(SPEC)
	$(MAKE) clean-tmp

test: check-activate prep
	rpmbuild -bi $(SPEC)
	$(MAKE) clean-tmp

active: activate

activate:
    ifeq ($(shell test -L $(RPMBUILDDIR); echo $$?), 0)
		rm -f $(RPMBUILDDIR)
    else ifeq ($(shell test -d $(RPMBUILDDIR); echo $$?), 0)
		mv -f $(RPMBUILDDIR) $(RPMBUILDDIR).old
    else
		rm -f $(RPMBUILDDIR)
    endif
	ln -s $(WORKDIR) $(RPMBUILDDIR)

check-activate:
    ifneq ($(ACTIVEDIR), $(WORKDIR))
		$(error project is not active)
    endif

clean-tmp:
	rm -rf $(BUILDDIR)
	rm -rf $(BUILDROOTDIR)
	
clean-pkg:
	rm -rf $(RPMSDIR)
	rm -rf $(SRPMSDIR)

clean: clean-tmp clean-pkg
	rm -f $(SOURCESDIR)/$(NAME)-*.tar.gz
