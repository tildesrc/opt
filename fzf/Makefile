REPO=https://github.com/junegunn/fzf

install: preconfigure
	src/install --completion --key-bindings --update-rc --no-zsh

include ../git.makefile.defs
include ../base.makefile.defs

uninstall:
	! [ -x src/uninstall ] || src/uninstall
