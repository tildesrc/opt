REPO=https://github.com/RichiH/vcsh
DEPENDENCIES=libtest-most-perl libshell-command-perl ronn

install: preconfigure
	env PREFIX=$(shell pwd) make -C src install

include ../git.makefile.defs
include ../base.makefile.defs

