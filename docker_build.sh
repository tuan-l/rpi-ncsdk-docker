#!/bin/bash
docker build --cpu-shares 1024 -t arm32v7/xenial:python -f Dockerfile_base .
docker build --cpu-shares 1024 -t arm32v7/xenial:tensorflow -f Dockerfile_base_tensorflow .
docker build --cpu-shares 1024 -t arm32v7/xenial:ncsdk -f Dockerfile_base_final .
