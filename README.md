# rpi-ncsdk-docker
Intel [Intel® Movidius™ Neural Compute SDK](https://github.com/movidius/ncsdk) docker image for Raspberry Pi.

```bash
docker run -it --rm --net=host --privileged -v /dev/bus/usb:/dev/bus/usb -v /ncappzoo/:/ncappzoo:rw ggtuanlm/rpi-ncsdk:privileged
```
