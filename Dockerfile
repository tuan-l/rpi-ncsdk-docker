# Stage 1: build base image with prequisite packages
FROM arm32v7/ubuntu:xenial as ncsdk_python
LABEL maintainer="tuanlm@greenglobal.vn"

# Enable QEMU for ARM to build ARM image on X86 machine
COPY ./qemu-arm-static /usr/bin/qemu-arm-static

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# Install necessary packages for the installer
RUN apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get autoremove -y
RUN apt-get install update-manager-core -y

RUN apt-get install --fix-missing -y \
    apt-utils lsb-release build-essential apt-transport-https \
    usbutils unzip coreutils curl git sed sudo tar udev wget \
    automake cmake make libusb-1.0-0-dev libatlas-base-dev \
    libopenblas-dev libprotobuf-dev libleveldb-dev libsnappy-dev \
    libopencv-dev libhdf5-serial-dev libgflags-dev libgoogle-glog-dev \
    liblmdb-dev libxslt-dev libxml2-dev libgraphviz-dev protobuf-compiler \
    byacc swig3.0 graphviz gfortran python-dev python-numpy python-pip python3 \
    python3-dev python3-numpy python3-scipy python3-yaml python3-nose python3-tk python3-pip

# Run the installer
COPY pip.conf /etc/pip.conf
# RUN pip install --upgrade pip
# RUN pip install virtualenv virtualenv-tools
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python2 get-pip.py && \
    python3 get-pip.py

RUN pip3 install -U "Cython>=0.23.4,<=0.26"
RUN pip3 install "pygraphviz>=1.3.1" "graphviz>=0.4.10,<=0.8" "Enum34>=1.1.6" "networkx>=2.1,<=2.1"

# Do clean jobs
RUN sudo apt-get clean && sudo apt-get autoremove



# Stage 2: Install Tensorflow
FROM ncsdk_python as ncsdk_tensorflow
LABEL maintainer="tuanlm@greenglobal.vn"

# Fix libstdc++.so.6: version `GLIBCXX_3.4.22' not found
# when import tensorflow
# https://github.com/lhelontra/tensorflow-on-arm/issues/13
RUN sudo apt-get install -y software-properties-common
# RUN sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
#     sudo apt-get update && \
#     sudo apt-get -y install gcc-4.9 && \
#     sudo apt-get -y upgrade libstdc++6

# Install Tensorflow and Scikit-image
ENV TF_VERSION 1.9.0
ENV TENSORFLOW tensorflow-${TF_VERSION}-cp35-none-linux_armv7l.whl
ENV SKI_VERSION 0.13.0
ENV SK_IMAGE scikit_image-${SKI_VERSION}-cp35-cp35m-linux_armv7l.whl
ENV NP_VERSION 1.13.0
ENV NUMPY numpy-${NP_VERSION}-cp35-cp35m-linux_armv7l.whl

# Copy over the Numpy wheel file
COPY ./installation/${NUMPY} .
# Install tensorflow
RUN pip3 install ./${NUMPY}

# Copy over the Scikit-image wheel file
COPY ./installation/${SK_IMAGE} .
# Install Scikit-image
RUN pip3 install ./${SK_IMAGE}

# Copy over the Tensorflow wheel file
COPY ./installation/${TENSORFLOW} .
# Install tensorflow
RUN pip3 install ./${TENSORFLOW}

# Do clean jobs
RUN rm -rf /${TENSORFLOW}
RUN rm -rf /${SK_IMAGE}
RUN rm -rf /${NUMPY}
RUN sudo apt-get clean && sudo apt-get autoremove



# Stage 3: Install NCSDK
FROM ncsdk_tensorflow as ncsdk_final
LABEL maintainer="tuanlm@greenglobal.vn"

# Copy over the NCSDK
COPY ./ncsdk /ncsdk

# install ncsdk
WORKDIR /ncsdk
RUN make install

# Enable NoPrivileges mode for NCS devices
WORKDIR /ncsdk/api/src
RUN sudo make get_mvcmd && \
    sudo make basicinstall NO_BOOT=yes NO_RESET=yes && \
    sudo make pythoninstall

WORKDIR /

# Do clean jobs
RUN sudo apt-get clean && sudo apt-get autoremove

# Expose some newly-created images information
RUN echo `python3 -c "from mvnc import mvncapi; print('NCAPI Version:', mvncapi.global_get_option(mvncapi.GlobalOption.RO_API_VERSION))"`
RUN lsb_release -a
RUN uname -a
