TOPTARGETS = install build preconfigure configure sudo-configure post-configure src list-dependencies require-dependencies install-local-packages pip3-dependencies clean
SUBDIR_EXLUDES= dot/. apt-packages/. opt/. test/.
SUBDIRS = apt-packages/. $(filter-out $(SUBDIR_EXLUDES), $(wildcard */.))
DEPLOY_FILES=$(shell git ls-files) .git
DEPLOY_TAR=$(shell realpath deploy.tar)
SSH_AUTH_SOCK_DIR=$(shell dirname $(SSH_AUTH_SOCK))

default: dependencies
	make install
	make post-configure

dependencies:
	make require-dependencies || make install-dependencies

install-dependencies:
	! [ -e task-opt.includes ] || rm --verbose task-opt.includes
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

deploy.tar: $(DEPLOY_FILES) vcsh
	tar --transform='s:^:opt/:' --create --file "$(DEPLOY_TAR)" $(DEPLOY_FILES)
	cd ~ && tar --append --file "$(DEPLOY_TAR)" .ssh/ .config/vcsh
	cd ~ && vcsh list | while read repo; do vcsh "$$repo" ls-files; done | xargs tar --append --file "$(DEPLOY_TAR)"

test: test/Dockerfile.debian.buster deploy.tar
	docker build -f test/Dockerfile.debian.buster -t opt .

run-test: 
	docker run --tty --interactive --volume "$(SSH_AUTH_SOCK_DIR):$(SSH_AUTH_SOCK_DIR)" --env "SSH_AUTH_SOCK=$(SSH_AUTH_SOCK)" -t opt fish --login

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
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
