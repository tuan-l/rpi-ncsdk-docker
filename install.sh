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
sed -i -e 's/--trusted-host files.pythonhosted.org//' ncsdk/install.sh


# index-url for Python wheel
PY_WHEEL=https://www.piwheels.hostedpi.com/simple
mkdir -p installation
# Download pre-built Tensorflow wheel
TF_VERSION=1.9.0
TENSORFLOW=tensorflow-${TF_VERSION}-cp35-none-linux_armv7l.whl
wget -O installation/${TENSORFLOW} -nc ${PY_WHEEL}/tensorflow/${TENSORFLOW}
# wget -O installation/${TENSORFLOW} -nc https://github.com/lhelontra/tensorflow-on-arm/releases/download/v${TF_VERSION}/${TENSORFLOW}

# Download pre-built Scikit-image wheel
SKI_VERSION=0.13.0
SK_IMAGE=scikit_image-${SKI_VERSION}-cp35-cp35m-linux_armv7l.whl
wget -O installation/${SK_IMAGE} -nc ${PY_WHEEL}/scikit-image/${SK_IMAGE}

# Download pre-built Numpy wheel
NP_VERSION=1.13.0
NUMPY=numpy-${NP_VERSION}-cp35-cp35m-linux_armv7l.whl
wget -O installation/${NUMPY} -nc ${PY_WHEEL}/numpy/${NUMPY}



# Build docker images
# . ./docker_build.sh
docker build --rm -f "Dockerfile" -t rpi-ncsdk-docker:latest .

# Run interactive ncsdk docker image for utilizing
. ./docker_run.sh
