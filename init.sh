#!/bin/bash
export UID=$(id -u)
export GID=$(id -g)

echo "Using UID: $UID and GID: $GID"

if [[ "$1" == "--fresh-start" ]]; then
    echo "Starting with a fresh setup..."
    docker compose -f docker/docker-compose.yml up init-project --build
else
    echo "No --fresh-start flag provided. Proceeding with the default setup..."
fi

exit $?