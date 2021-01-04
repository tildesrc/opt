PRECONFIGURE_REQS = src require-dependencies
LOCAL_PACKAGES = $(wildcard *.deb)

ifdef PIP3_DEPENDENCIES
	APT_DEPENDENCIES += python3-pip
	PRECONFIGURE_REQS += pip3-dependencies
endif

preconfigure: $(PRECONFIGURE_REQS)

list-dependencies:
	echo "$(APT_DEPENDENCIES)" | sed -e 's/\s\+/\n/g' | sed -n '/\S/p' >> ../tasks/task-opt.includes

require-dependencies: $(APT_DEPENDENCIES)

install-local-packages: $(LOCAL_PACKAGES)
ifneq ($(LOCAL_PACKAGES),)
	for package in $(LOCAL_PACKAGES); do \
		if ! ../scripts/check_dependencies.sh $$(dpkg-deb --show --showformat '$${Package}' $$package); then \
			apt-get install --assume-yes ./$$package; \
		fi; \
	done
endif

$(APT_DEPENDENCIES):
	../scripts/check_dependencies.sh $@

pip3-dependencies:
	pip3 install $(PIP3_DEPENDENCIES)

uninstall:

sudo-configure:

post-configure:

download-debs:
ifdef PACKAGE_URLS
	for url in $(PACKAGE_URLS); do \
		curl --continue-at - --remote-name $$url; \
	done
endif

clean: uninstall
	find . -not \( -path ./Makefile -or -path './*.deb' \) -delete

# vi: ft=make
