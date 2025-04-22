#!/bin/bash

export UID=$(id -u)
export GID=$(id -g)

export IMAGE_LATEST=serversideup/laravel:8.3-fpm-nginx-bookworm
export DOCKER_FILE=docker/Dockerfile

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
    cp docker/scripts/example.env .env
    docker compose \
        --env-file=.env \
        -f docker/docker-compose.yml \
        up \
        init-project postgres \
        --build
    echo -e "${GREEN}Initialization complete!${NC}"
    echo "You can start an interactive session with the following command:"
    echo "./init.sh --it"

elif [[ "$1" == "--it" ]]; then
    echo "Running in interactive mode..."
    trap cleanup EXIT
    docker exec -it laravel-app /bin/bash


elif [[ "$1" == "--dev" ]]; then
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
    docker compose \
        --env-file=.env \
        -f docker/docker-compose.yml \
        up \
        -d \
        postgres php
    docker exec -it laravel-app /bin/bash

elif [[ "$1" == "--build-prod" ]]; then
    echo ">>> Run building image..."
    docker build \
    --cache-from $IMAGE_LATEST \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --target production \
    --tag $IMAGE_LATEST \
    --file $DOCKER_FILE \
    "."
    echo "Image build successfully!"
    # Ask user if they want to proceed with --run-prod
    read -p "Do you want to proceed with running the production environment? (y/n): " user_input
    case $user_input in
        [Yy]* )
            echo ">>> Proceeding with running production..."
            ./init.sh --run-prod
            ;;
        [Nn]* )
            echo ">>> Skipping production run."
            ;;
        * )
            echo "Invalid input. Please enter 'y' or 'n'."
            ;;
    esac

elif [[ "$1" == "--run-prod" ]]; then
    trap cleanup EXIT
    docker compose \
        --env-file=.env \
        -f docker/docker-compose.yml \
        up -d prod postgres

elif [[ "$1" == "--down" ]]; then
    cleanup

else
    echo "Invalid option. Use --fresh-start, --build-prod, --run-prod, --dev, --down or --it"
fi

exit $?
