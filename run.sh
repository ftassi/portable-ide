#!/bin/sh
xhost +si:localuser:$USER > /dev/null
path=$(dirname $(realpath $0))

docker run --rm -it -h dev \
    -e HOST_USER_ID=$(id -u $USER) \
    -e HOST_GROUP_ID=$(id -g $USER) \
    -e DISPLAY=$DISPLAY \
    -e SSH_AUTH_SOCK=/ssh-agent \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $SSH_AUTH_SOCK:/ssh-agent \
    -v $HOME/.ssh:/home/me/.ssh \
    -v $HOME:/home/me/host \
    -v $path/config:/home/me/dotfiles \
    -v $path/data/.local/share:/home/me/.local/share \
    --name ide \
    portable-ide 
