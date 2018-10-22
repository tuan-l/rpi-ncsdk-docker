# Run interactive ncsdk docker image for utilizing
docker_cmd="docker run --net=host -v /dev:/dev:shared --name ncsdk -i -t arm32v7/xenial:ncsdk /bin/bash"

echo $docker_cmd
eval $docker_cmd
