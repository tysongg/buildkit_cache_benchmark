#!/bin/bash
set -e

DOCKER_FILE=$1
DOCKER_CONTEXT=$2
DOCKER_BASETAG=$3

# Load Functions
source functions.sh

# Start local registry
docker run -d -p 5000:5000 --name registry registry:2 || true

# Test builds with cache
echo "DOCKER: CACHE"
cleanLocal $DOCKER_BASETAG
time build docker $DOCKER_FILE $DOCKER_CONTEXT $DOCKER_BASETAG True
docker push ${DOCKER_BASETAG}:docker

echo "BUILDKIT: CACHE"
cleanLocal $DOCKER_BASETAG
time build buildkit $DOCKER_FILE $DOCKER_CONTEXT $DOCKER_BASETAG True
docker push ${DOCKER_BASETAG}:buildkit
