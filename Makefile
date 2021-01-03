TOPTARGETS = install build preconfigure configure sudo-configure post-configure src list-dependencies require-dependencies install-local-packages pip3-dependencies clean download-debs
SUBDIR_EXCLUDES = dot apt-packages opt test
SUBDIRS = apt-packages $(filter-out $(SUBDIR_EXCLUDES), $(patsubst %/.,%, $(wildcard */.)))
ifneq ($(which vcsh),)
	HOME_DEPLOY_FILES = $(HOME)/.ssh $(HOME)/.gnupg $(HOME)/.config/vcsh $(shell cd $(HOME) && vcsh list-tracked)
endif
REPO_DEPLOY_FILES = $(patsubst %,$(PWD)/%,$(shell git ls-files) .git)
DEPLOY_FILES = $(REPO_DEPLOY_FILES) $(HOME_DEPLOY_FILES)
DEPLOY_TAR=$(shell realpath deploy.tar)
SSH_AUTH_SOCK_DIR=$(shell dirname $(SSH_AUTH_SOCK))

default: dependencies
	make install
	make post-configure

dependencies:
	make require-dependencies || make install-dependencies

install-dependencies:
	! [ -e task-opt.includes ] || rm --verbose task-opt.includes
	make download-debs
	make list-dependencies
	touch task-opt.excludes
	./build-task.sh task-opt
	sudo make install-packages

install-packages:
	make install-local-packages
	make install-task-opt
	make sudo-configure

install-task-%: task-%_current_all.deb
	apt-get install  --assume-yes ./$<
	./mark-task-depends.sh $<

deploy.tar: vcsh $(DEPLOY_FILES)
	cd $(HOME) && tar --create --file "$(DEPLOY_TAR)" $(patsubst $(HOME)/%,%,$(DEPLOY_FILES))

test: deploy.tar
	make -C test

base-system:
	-./get-task-depends.sh task-base > task-base.includes
	apt-mark showmanual >> task-base.includes
	cp task-base.manual-excludes task-base.excludes
	-./get-task-depends.sh task-opt >> task-base.excludes
	echo "$$TASK_EXCLUDES" | sed -e 's/^\s*//' -e 's/\s*$$//' -e 's/\s\+/\n/g'>> task-base.excludes
	./build-task.sh task-base
	sudo --preserve-env=TASK_EXCLUDES make install-task-base

clean:
	-rm task-*includes task-*.excludes task-*.deb task-opt task-base deploy.tar

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(filter $(TOPTARGETS),$(MAKECMDGOALS))

.PHONY: $(TOPTARGETS) $(SUBDIRS)
