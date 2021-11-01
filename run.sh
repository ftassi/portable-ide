#!/bin/sh
docker run --rm -it -h dev \
    -e HOST_USER_ID=$(id -u $USER) \
    -e HOST_GROUP_ID=$(id -g $USER) \
    -e SSH_AUTH_SOCK=/ssh-agent \
    -v $PWD/config:/home/me/dotfiles \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $SSH_AUTH_SOCK:/ssh-agent \
    -v $PWD:/home/me/workspace \
    --name ide \
    portable-ide 
