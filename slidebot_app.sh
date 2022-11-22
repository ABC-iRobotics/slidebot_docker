#!/bin/bash
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
docker run --rm -v $XSOCK:$XSOCK:rw -v $XAUTH:$XAUTH:rw --device=/dev/dri/card0:/dev/dri/card0 -e DISPLAY=$DISPLAY -e XAUTHORITY=$XAUTH --network host -it ghcr.io/abc-irobotics/slidebot_docker_app:master
