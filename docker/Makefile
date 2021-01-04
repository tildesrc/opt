APT_DEPENDENCIES=docker.io

install:

sudo-configure:
	service docker start
	usermod --append --groups docker $(OPT_USER)

include ../defs/base.makefile

