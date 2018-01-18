FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04

# denotes whether shared or static tensorflow is built
ARG shared=OFF

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get -y update
RUN apt-get -y install build-essential curl git cmake unzip autoconf autogen libtool mlocate zlib1g-dev \
                       g++-6 python python3-numpy python3-dev python3-pip python3-wheel wget
RUN apt-get -y clean
# when building TF with Intel MKL support, `locate` database needs to exist
RUN updatedb

# copy the contents of this repository to the container
COPY . tensorflow_cc
# alternatively, clone the repository
# RUN git clone https://github.com/FloopCZ/tensorflow_cc.git

# install tensorflow
RUN mkdir /tensorflow_cc/tensorflow_cc/build
WORKDIR /tensorflow_cc/tensorflow_cc/build
# configure only shared or only static library
RUN if [ "${shared}" = "OFF" ]; then \
        cmake ..; \
    else \
        cmake -DTENSORFLOW_STATIC=OFF -DTENSORFLOW_SHARED=ON ..; \
    fi
# build
RUN make
# cleanup after bazel
RUN rm -rf ~/.cache
# install
RUN make install

# build and run example
RUN mkdir /tensorflow_cc/example/build
WORKDIR /tensorflow_cc/example/build
RUN cmake .. && make && ./example
