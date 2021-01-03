FROM debian:buster

# vi: ft=docker
ENV DEBIAN_FRONTEND="noninteractive" 
RUN apt-get update
RUN apt-get install --assume-yes make sudo equivs

ADD test/su /etc/pam.d/su
ADD test/sudoers /etc/sudoers

RUN groupadd test_group
RUN useradd --create-home --shell /bin/bash --group test_group test_user

COPY --chown=test_user:test_group deploy.tar /home/test_user/

USER test_user
RUN cd ~ && tar --verbose --extract --file deploy.tar
WORKDIR /home/test_user/opt
RUN "./init.sh"

ENTRYPOINT ["bash", "--login"]

# vi: ft=dockerfile
