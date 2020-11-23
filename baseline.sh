#!/bin/bash
set -e

DOCKER_FILE=$1
DOCKER_CONTEXT=$2
DOCKER_BASETAG=$3

# Load Functions
source functions.sh

# Start local registry
docker run -d -p 5000:5000 --name registry registry:2 || true

# Adding python to local registry
docker pull python:3.8.5-buster
docker tag python:3.8.5-buster localhost:5000/python:3.8.5-buster
docker push localhost:5000/python:3.8.5-buster

# Test builds with no cache
echo "DOCKER: NO-CACHE"
docker image remove ${DOCKER_BASETAG}:docker || true
cleanLocal $DOCKER_BASETAG
time build docker $DOCKER_FILE $DOCKER_CONTEXT $DOCKER_BASETAG
docker push "${DOCKER_BASETAG}:docker"

echo "BUILDKIT: NO-CACHE"
cleanLocal $DOCKER_BASETAG
time build buildkit $DOCKER_FILE $DOCKER_CONTEXT $DOCKER_BASETAG
docker push "${DOCKER_BASETAG}:buildkit"