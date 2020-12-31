TOPTARGETS = install build preconfigure configure src list-dependencies require-dependencies pip3-dependencies clean
SUBDIR_EXLUDES= dot/. apt-packages/.
SUBDIRS = apt-packages/. $(filter-out $(SUBDIR_EXLUDES), $(wildcard */.))

default: dependencies install

dependencies:
	make require-dependencies || make install-dependencies

install-dependencies:
	! [ -e task-opt.includes ] || rm --verbose task-opt.includes
	make list-dependencies
	touch task-opt.excludes
	./build-task.sh task-opt
	sudo make install-task-opt

install-task-%: task-%_current_all.deb
	apt-get install --autoremove  --assume-yes ./$<
	./mark-task-depends.sh $<

image: Dockerfile
	docker build -t opt .

test: image
	! [ -e test.tar ] || rm --verbose test.tar
	tar --no-recursion --create --file test.tar * */Makefile
	docker run -t opt

base-system:
	-./get-task-depends.sh task-base > task-base.includes
	apt-mark showmanual >> task-base.includes
	cp task-base.manual-excludes task-base.excludes
	-./get-task-depends.sh task-opt >> task-base.excludes
	./build-task.sh task-base
	sudo make install-task-base

clean:
	-rm task-*includes task-*.excludes task-*.deb task-opt task-base test.tar

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
