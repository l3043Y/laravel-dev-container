#!/bin/bash

export UID=$(id -u)
export GID=$(id -g)
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export NC='\033[0m' # No Color


function cleanup {
    echo ""
    echo -e "${RED}Stopping and cleaning up Docker containers...${NC}"
    echo ""
    docker compose -f docker/docker-compose.yml down
}

if [[ "$1" == "--fresh-start" ]]; then
    echo "Starting with a fresh setup..."
    echo -e "${GREEN}UID: ${UID}${NC}"
    echo -e "${GREEN}GID: ${GID}${NC}"
    docker compose -f docker/docker-compose.yml up init-project --build

elif [[ "$1" == "--it" ]]; then
    echo "Running in interactive mode..."
    docker exec -it laravel-dev /bin/bash

elif [[ "$1" == "--dev" ]]; then
    echo "Running in interactive mode..."
    docker exec -it laravel-dev /bin/bash

elif [[ "$1" == "--down" ]]; then
    cleanup

else
    echo ""
    echo -e "${GREEN}Dev Container Running...${NC}"
    echo -e "${GREEN}Image: serversideup/php:8.3-fpm-nginx-bookworm${NC}"
    echo -e "${GREEN}Host: 127.0.0.1${NC}"
    echo -e "${GREEN}Port: 8000${NC}"
    echo -e "${GREEN}UID: ${UID}${NC}"
    echo -e "${GREEN}GID: ${GID}${NC}"
    echo ""
    echo -e "${GREEN}alias art=\"php artisan\"${NC}"
    echo ""
    trap cleanup EXIT
    docker compose -f docker/docker-compose.yml up -d php
    docker exec -it laravel-dev /bin/bash
fi

exit $?
