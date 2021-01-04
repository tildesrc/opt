install-dependencies:
	! [ -e task-opt.includes ] || rm --verbose task-opt.includes
	make -C .. download-debs
	make -C .. list-dependencies
	touch task-opt.excludes
	./build-task.sh task-opt
	OPT_USER=$(shell id --user --name) sudo --preserve-env=OPT_USER make install-packages

install-packages:
	make -C .. install-local-packages
	make install-task-opt
	make -C .. sudo-configure

install-task-%: task-%_current_all.deb
	apt-get install  --assume-yes ./$<
	./mark-task-depends.sh $<

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
