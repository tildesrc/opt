define require-dependency
	dpkg-query --show --showformat='$${db:Status-Status}' $@ | grep --line-regexp --fixed-strings 'installed'
endef

install: build
	make -C src install

build: configure
	make -C src

configure: preconfigure
	src/configure --prefix="$(shell pwd)" $(CONFIGURE_OPTS)

# vi: ft=make
