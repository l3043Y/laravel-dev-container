ARG BASE_IMAGE='serversideup/php'
ARG BASE_IMAGE_VARS='fpm-nginx-bookworm'
ARG PHP_VERSION='8.3'
FROM ${BASE_IMAGE}:${PHP_VERSION}-${BASE_IMAGE_VARS} AS base
ARG CI_JOB_TOKEN

ENV AUTORUN_ENABLED=false
ENV SSL_MODE=off

# INSTALLING BUILD TOOLS
USER root
RUN install-php-extensions xml xsl bcmath gd mbstring curl http intl
RUN install-php-extensions opentelemetry-stable

# INSTALLING HANDY TOOLS
RUN apt-get update
RUN apt-get -y install netcat-openbsd vim telnet

# CLEANING UP...
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# COPY IN NGINX CONFIGURATION
COPY --chown=www-data:www-data docker/scripts/15-disable-ipv6.sh /etc/entrypoint.d/
RUN chmod +x /etc/entrypoint.d/15-disable-ipv6.sh

USER www-data
RUN echo "alias art=\"php artisan\"" > ~/.profile
RUN echo "alias" >> ~/.profile
RUN echo "source ~/.profile" > ~/.bashrc
############################################
# INIT PROJECT
############################################
FROM base AS init-project
USER root

ARG USER_ID
ARG GROUP_ID

RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

COPY --chown=www-data:www-data docker/scripts/init-laravel.sh /etc/entrypoint.d/0-init-laravel.sh
COPY --chown=www-data:www-data docker/scripts/example.env /etc/entrypoint.d/.env
RUN chmod +x /etc/entrypoint.d/0-init-laravel.sh

USER www-data
############################################
# Development Image
############################################
FROM base AS development
USER root

ARG USER_ID
ARG GROUP_ID

RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    # Update the file permissions for our NGINX service to match the new UID/GID
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

# Drop back to our unprivileged user
USER www-data
############################################
# Prebuild Image
############################################
FROM base AS prebuild
WORKDIR /var/www/html
USER www-data

# Copy only composer files and install dependencies
COPY --chown=www-data:www-data composer.json composer.lock ./
RUN composer config gitlab-token.gitlab.com gitlab-ci-token "${CI_JOB_TOKEN}"
RUN composer install \
        --apcu-autoloader \
        --ansi \
        --no-dev \
        --no-interaction \
        --no-scripts \
        --prefer-dist \
        --optimize-autoloader

# CLEANING UP...
RUN rm -f auth.json
############################################
# Production Image
############################################
FROM prebuild as production
WORKDIR /var/www/html
ENV PHP_OPCACHE_ENABLE=1

# Copy our app files as www-data (33:33)
COPY --chown=www-data:www-data . .
USER www-data
