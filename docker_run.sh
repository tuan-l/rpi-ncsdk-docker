docker_cmd="docker run --net=host --privileged"
docker_cmd="$docker_cmd -v /dev/bus/usb/:/dev/bus/usb/:ro"
docker_cmd="$docker_cmd -v /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static:ro"
docker_cmd="$docker_cmd --name ncsdk -i -t arm32v7/xenial:ncsdk /bin/bash"

echo $docker_cmd
eval $docker_cmd
