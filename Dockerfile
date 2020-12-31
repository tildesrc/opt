FROM debian:stable
RUN apt-get update
RUN apt-get install --assume-yes make sudo

COPY . /opt
WORKDIR /opt

ENTRYPOINT [ "make" ]
#ENTRYPOINT [ "bash", "--login" ]
