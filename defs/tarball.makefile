APT_DEPENDENCIES += curl

install: preconfigure
	tar --verbose --strip-components=1 --extract --file src.tar

src:
	curl --location $(TARBALL_URL) --output src.tar

# vi: ft=make
