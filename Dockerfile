FROM ubuntu:14.10
MAINTAINER Akihiro HARAI

#https://github.com/docker/docker/issues/6345
#https://registry.hub.docker.com/u/sequenceiq/pam/dockerfile/
#Setup build environment for libpam
RUN apt-get update && apt-get -y build-dep pam
#Rebuild and istall libpam with --disable-audit option
RUN export CONFIGURE_OPTS=--disable-audit && cd /root && \
 apt-get -b source pam && dpkg -i libpam-doc*.deb libpam-modules*.deb \
 libpam-runtime*.deb libpam0g*.deb

RUN adduser --disabled-password --home /home/caffe --gecos "" caffe
RUN echo "caffe ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/caffe
RUN chmod 0440 /etc/sudoers.d/caffe

RUN apt-get update && apt-get install -y libprotobuf-dev \
 libleveldb-dev libsnappy-dev libopencv-dev libboost-all-dev \
 libhdf5-serial-dev libgflags-dev libgoogle-glog-dev liblmdb-dev \
 protobuf-compiler libopenblas-base libopenblas-dev python-dev \
 python-pip
RUN apt-get install -y git
WORKDIR /home/caffe
RUN sudo -u caffe git clone https://github.com/BVLC/caffe.git
WORKDIR /home/caffe/caffe



ENTRYPOINT /usr/bin/sudo -u caffe -i
