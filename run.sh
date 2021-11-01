#!/bin/sh
docker run --rm -it -h dev \
    -e HOST_USER_ID=$(id -u $USER) \
    -e HOST_GROUP_ID=$(id -g $USER) \
    -e SSH_AUTH_SOCK=/ssh-agent \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $SSH_AUTH_SOCK:/ssh-agent \
    -v $HOME/.ssh/config:/home/me/.ssh/config \
    -v $HOME/.ssh/id_rsa:/home/me/.ssh/id_rsa:ro \
    -v $HOME/.ssh/id_rsa.pub:/home/me/.ssh/id_rsa.pub:ro \
    -v $PWD/config:/home/me/dotfiles \
    -v $PWD:/home/me/workspace \
    --name ide \
    portable-ide 
