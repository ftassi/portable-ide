#!/bin/sh
DOCKER_BUILDKIT=1 docker build . -t portable-ide --ssh default
