TOPTARGETS = install build preconfigure configure src install-dependencies require-dependencies clean
SUBDIR_EXLUDES= dot/.
SUBDIRS = $(filter-out $(SUBDIR_EXLUDES), $(wildcard */.))

default:
	make require-dependencies || sudo make install-dependencies
	make install

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
