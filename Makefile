TOPTARGETS = install build preconfigure configure src list-dependencies require-dependencies pip3-dependencies clean
SUBDIR_EXLUDES= dot/. apt-packages/.
SUBDIRS = apt-packages/. $(filter-out $(SUBDIR_EXLUDES), $(wildcard */.))

default: dependencies install

dependencies:
	make require-dependencies || make install-dependencies

install-dependencies:
	! [ -e dependencies ] || rm --verbose dependencies
	make list-dependencies
	./create-task-opt.sh
	sudo make install-task-opt

install-task-opt:
	apt-get install --autoremove  --assume-yes ./task-opt_current_all.deb
	./mark-task-opt-depends.sh

image: Dockerfile
	docker build -t opt .

test: image
	make clean
	docker run -t opt

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
