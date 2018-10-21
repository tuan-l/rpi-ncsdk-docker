# Stage 1: build base image with prequisite packages
FROM arm32v7/ubuntu:xenial as ncsdk_python

# Enable QEMU for ARM to build ARM image on X86 machine
COPY ./qemu-arm-static /usr/bin/

# Install necessary packages for the installer
RUN apt-get update && \
    apt-get dist-upgrade && \
    apt-get autoremove
RUN apt-get install update-manager-core -y

RUN apt-get install --fix-missing -y \
    apt-utils \
    lsb-release \
    build-essential \
    sed \
    sudo \
    tar \
    udev \
    wget \
    libusb-1.0-0-dev \
    python-dev \
    python3-dev \
    libatlas-base-dev \
    libopenblas-dev \
    apt-transport-https \
    usbutils

# Fix debconf: (No usable dialog-like program is installed, so the dialog based frontend cannot be used)
# https://nesterof.com/blog/2017/09/21/debconf-no-usable-dialog-like-program-is-installed-so-the-dialog-based-frontend-cannot-be-used/
# RUN sudo apt-get install dialog whiptail -y

# Run the installer
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python2 get-pip.py && \
    python3 get-pip.py

# Do clean jobs
RUN sudo apt-get clean && sudo apt-get autoremove



# Stage 2: Install Tensorflow
FROM ncsdk_python as ncsdk_tensorflow

# Fix libstdc++.so.6: version `GLIBCXX_3.4.22' not found
# when import tensorflow
# https://github.com/lhelontra/tensorflow-on-arm/issues/13
RUN sudo apt-get install -y software-properties-common
RUN sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    sudo apt-get update && \
    sudo apt-get -y install gcc-4.9 && \
    sudo apt-get -y upgrade libstdc++6

# https://github.com/lhelontra/tensorflow-on-arm/releases/download/v1.9.0/tensorflow-1.9.0-cp35-none-linux_armv7l.whl
ENV TF_VERSION 1.9.0
ENV TENSORFLOW tensorflow-${TF_VERSION}-cp35-none-linux_armv7l.whl
# RUN wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v${TF_VERSION}/${TENSORFLOW}

# Copy over the Tensorflow wheel file
COPY ./installation/${TENSORFLOW} .

# Install tensorflow
RUN pip3 install ./${TENSORFLOW}
RUN rm -rf /${TENSORFLOW}

# Do clean jobs
RUN sudo apt-get clean && sudo apt-get autoremove



# Stage 3: Install NCSDK
FROM ncsdk_tensorflow as ncsdk_final

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
