REPO=https://github.com/RichiH/vcsh
APT_DEPENDENCIES=libtest-most-perl libshell-command-perl ronn

post-configure: install
	bin/vcsh foreach config core.worktree $(HOME)

install: preconfigure
	env PREFIX=$(shell pwd) make -C src install

include ../git.makefile.defs
include ../base.makefile.defs

