SUBDIRS = $(patsubst %/.,%,$(wildcard */.))

images: $(SUBDIRS:=.build)

%.run: 
	docker run --tty --interactive --volume "$(SSH_AUTH_SOCK_DIR):$(SSH_AUTH_SOCK_DIR)" --env "SSH_AUTH_SOCK=$(SSH_AUTH_SOCK)" -t opt:$* fish --login

%.build: %/Dockerfile
	docker build -f $< -t opt:$* ..

%/Dockerfile: %/Dockerfile.stub Dockerfile.base 
	cat $< Dockerfile.base > $@

clean: $(SUBDIRS:=.clean)

%.clean:
	-rm $*/Dockerfile

