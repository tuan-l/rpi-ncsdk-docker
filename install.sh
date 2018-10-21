#!/bin/bash

# Setting up qemu for build arm image on x86 machine
. ./qemu_install.sh

# Prepare files for later use
# Download ncsdk from github
git clone https://github.com/movidius/ncsdk.git -b ncsdk2 --depth=1
rm -rf ncsdk/.git ncsdk/docs
sed -i -e 's/INSTALL_CAFFE=yes/INSTALL_CAFFE=no/' ncsdk/ncsdk.conf
sed -i -e 's/INSTALL_TENSORFLOW=yes/INSTALL_TENSORFLOW=no/' ncsdk/ncsdk.conf
sed -i -e 's/#MAKE_NJOBS=1/MAKE_NJOBS='`nproc`'/' ncsdk/ncsdk.conf

# Download pre-built Tensorflow wheel
TF_VERSION=1.9.0
TENSORFLOW=tensorflow-${TF_VERSION}-cp35-none-linux_armv7l.whl
mkdir -p installation
wget -O installation/${TENSORFLOW} -nc https://github.com/lhelontra/tensorflow-on-arm/releases/download/v${TF_VERSION}/${TENSORFLOW}

# Build docker images
. ./docker_build.sh

# Run interactive ncsdk docker image for utilizing
. ./docker_run.sh
