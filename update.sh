#!/bin/bash

IMAGE="lilaczhang/my_app:latest"
CONTAINER="myapp"

docker pull $IMAGE

CURRENT=$(docker inspect --format='{{index .RepoDigests 0}}' $CONTAINER 2>/dev/null || echo "")
LATEST=$(docker inspect --format='{{index .RepoDigests 0}}' $IMAGE)

if [ "$CURRENT" != "$LATEST" ]; then
  docker stop $CONTAINER || true
  docker rm $CONTAINER || true
  docker run -d -p 5000:5000 --name $CONTAINER $IMAGE
fi