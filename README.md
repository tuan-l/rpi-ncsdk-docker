# rpi-ncsdk-docker
_In this tutorial we're going to build Intel [Intel® Movidius™ Neural Compute SDK](https://github.com/movidius/ncsdk) docker image for Raspberry Pi on x86 machine._

1. First, install cross-compiling tool for building arm image on x86 machine
2. Clone Intel ncsdk to current directory
3. Download Tensorflow 1.9.0 wheel for arm
4. To build new docker image, run this command bellow on your favorite terminal
  ```sh
  docker build --rm -f "Dockerfile" -t rpi-ncsdk-docker:latest .
  ```
5. Run newly-built docker image for utilizing
