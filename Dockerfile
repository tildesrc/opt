FROM debian:stable
RUN apt-get update
RUN apt-get install --assume-yes make sudo equivs

ADD test.tar /opt
WORKDIR /opt

ENTRYPOINT [ "make" ]
