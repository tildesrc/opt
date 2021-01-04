TOPTARGETS = install build preconfigure configure sudo-configure post-configure src list-dependencies require-dependencies install-local-packages pip3-dependencies clean download-debs
SUBTARGET_EXCLUDES = dot apt-packages opt test tasks defs scripts
SUBTARGETS = apt-packages $(filter-out $(SUBTARGET_EXCLUDES), $(patsubst %/.,%, $(wildcard */.)))
ifneq ($(shell which vcsh),)
	HOME_DEPLOY_FILES = $(HOME)/.ssh $(HOME)/.gnupg $(HOME)/.password-store $(HOME)/.config/vcsh $(shell cd $(HOME) && vcsh list-tracked)
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

deploy.tar: vcsh $(DEPLOY_FILES)
	cd $(HOME) && tar --create --file "$(DEPLOY_TAR)" $(patsubst $(HOME)/%,%,$(DEPLOY_FILES))

test: deploy.tar
	make -C test

install-dependencies install-packages install-task base-system:
	make -C tasks $@

clean:
	make -C tasks clean
	-rm deploy.tar

$(TOPTARGETS): $(SUBTARGETS)
$(SUBTARGETS):
	$(MAKE) -C $@ $(filter $(TOPTARGETS),$(MAKECMDGOALS))

.PHONY: $(TOPTARGETS) $(SUBTARGETS)
