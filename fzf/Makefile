REPO=https://github.com/junegunn/fzf

install: preconfigure
	src/install --completion --key-bindings --update-rc --no-zsh

include ../defs/git.makefile
include ../defs/base.makefile

uninstall:
	! [ -x src/uninstall ] || src/uninstall
