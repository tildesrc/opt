TOPTARGETS = install build preconfigure configure src install-dependencies require-dependencies pip3-dependencies clean
SUBDIR_EXLUDES= dot/. apt-packages/.
SUBDIRS = apt-packages/. $(filter-out $(SUBDIR_EXLUDES), $(wildcard */.))

default: dependencies install

dependencies:
	make require-dependencies || sudo make install-dependencies

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
