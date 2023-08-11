# A Dockerfile to build and package pCloudCC from source
 
## By default the container will build pCloudCC and install it to /usr/bin/pcloudcc
# docker build . -t pcloudcc

## Optionally, build pCloudCC and produce a .deb package to /src/pcloudcc_2.0.1-1_amd64.deb 
# docker build . -t pcloudcc --build-arg PACKAGE=true

## Run the container:
# docker run -it pcloudcc

FROM ubuntu:22.04
ARG PACKAGE
RUN apt-get update \
  && apt-get install --yes \
    cmake \
    zlib1g-dev \
    libboost-system-dev \
    libboost-program-options-dev \
    libpthread-stubs0-dev \
    libfuse-dev \
    libudev-dev \
    fuse \
    build-essential \
    git
COPY . /src
WORKDIR /src/pCloudCC/lib/pclsync
RUN make clean \
  && make fs
WORKDIR /src/pCloudCC/lib/mbedtls
RUN cmake . \
  && make clean \
  && make  
WORKDIR /src/pCloudCC
RUN  cmake . \
  && make \
  && make install \
  && ldconfig 

# Conditionally produce a .deb package by specifying the PACKAGE
# docker build --build-arg PACKAGE=1
RUN if [ -n "${PACKAGE}" ] \
    ; then \
      apt-get install --yes \
        devscripts \
        debhelper \
    ; fi
RUN if [ -n "${PACKAGE}" ] \
    ; then \
      debuild -i -us -uc -b -d \
    ; fi

WORKDIR /src