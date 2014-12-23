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
 python-pip git curl

WORKDIR /home/caffe
USER caffe

RUN git clone https://github.com/BVLC/caffe.git
RUN mkdir -p downloads

WORKDIR /home/caffe/downloads

RUN curl -o anaconda.sh http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-2.1.0-Linux-x86_64.sh
RUN bash anaconda.sh -b
RUN echo export PYTHONPATH=/home/caffe/caffe/python:\$PYTHONPATH >> /home/caffe/.profile

WORKDIR /home/caffe/caffe

RUN cp Makefile.config.example Makefile.config
RUN echo CPU_ONLY := 1 >> Makefile.config
RUN echo BLAS := open >> Makefile.config
RUN echo 'PYTHON_INCLUDE := $(HOME)/anaconda/include \
 $(HOME)/anaconda/include/python2.7 \
 $(HOME)/anaconda/lib/python2.7/site-packages/numpy/core/include' >> Makefile.config
RUN echo 'PYTHON_LIB := $(HOME)/anaconda/lib' >> Makefile.config

RUN make all
RUN make test
RUN make runtest

ENTRYPOINT /usr/bin/sudo -u caffe -i
