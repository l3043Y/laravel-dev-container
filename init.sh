#!/bin/bash

# shellcheck disable=SC2155
export UID=$(id -u)
export GID=$(id -g)

export IMAGE_LATEST=serversideup/laravel:8.3-fpm-nginx-bookworm
export DOCKER_FILE=docker/Dockerfile
export COMPOSE_FILE=docker/docker-compose.yml
export ENV_FILE=docker/scripts/example.env
# shellcheck disable=SC2155

export PROJECT_NAME=$(basename "$PWD")
export PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
export APP_NAME=${PROJECT_NAME}-app

export RED="\033[0;31m"
export GREEN='\033[0;32m'
export NC='\033[0m' # No Color

if docker info &>/dev/null; then
    echo -e "${GREEN}Docker socket is running.${NC}"
else
    echo -e "${RED}Docker socket is NOT running.${NC}"
    exit 1
fi

function cleanup {
    echo ""
    echo -e "${RED}Stopping and cleaning up Docker containers...${NC}"
    echo ""
    docker compose -f $COMPOSE_FILE down
}

if [[ "$1" == "--fresh-start" ]]; then
    echo "Starting with a fresh setup..."
    echo -e "${GREEN}UID: ${UID}${NC}"
    echo -e "${GREEN}GID: ${GID}${NC}"

    export VOLUME_NAME=${PROJECT_NAME}-postgres-data

    echo "Initializing project: $PROJECT_NAME"
    sed -E "s/laravel-app/${APP_NAME}/g" docker/docker-compose.yml > tmp
    sed -E "s/postgres-data:/${VOLUME_NAME}:/g" tmp > tmp2
    rm -rf tmp
    mv tmp2 docker/docker-compose.yml

    if docker volume ls -q | grep -q "${VOLUME_NAME}"; then
        echo "Docker volume ${VOLUME_NAME} exists."
        read -p "Docker volume '${VOLUME_NAME}' exists. Remove it? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            docker volume rm "${VOLUME_NAME}"
            echo "Volume '${VOLUME_NAME}' removed."
        else
            echo -e "${RED}We can't proceed fresh setup with existing volume...${NC}"
            exit 1
        fi
    fi


    docker compose \
        --env-file=$ENV_FILE \
        -f $COMPOSE_FILE \
        up \
        init-project postgres \
        --build
    echo -e "${GREEN}Initialization complete!${NC}"
    echo "You can start an interactive session with the following command:"
    echo "./init.sh --it"

elif [[ "$1" == "--it" ]]; then
    echo "Running in interactive mode..."
    trap cleanup EXIT
    docker exec -it "$APP_NAME" /bin/bash


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
        --env-file=$ENV_FILE \
        -f $COMPOSE_FILE \
        up \
        -d \
        postgres php
    docker exec -it "$APP_NAME" /bin/bash

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
        --env-file=$ENV_FILE \
        -f $COMPOSE_FILE \
        up -d prod postgres

elif [[ "$1" == "--down" ]]; then
    cleanup

else
    echo "Invalid option. Use --fresh-start, --build-prod, --run-prod, --dev, --down or --it"
fi

exit $?
