### BASE
FROM serversideup/php:8.3-fpm-nginx-bookworm AS base
ENV AUTORUN_ENABLED=false
ENV SSL_MODE=off

# INSTALLING BUILD TOOLS
USER root
RUN install-php-extensions xml xsl bcmath gd mbstring curl
RUN install-php-extensions http intl

# INSTALLING HANDY TOOLS
RUN apt-get update
RUN apt-get -y install netcat-openbsd vim telnet || true

# CLEANING UP...
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* || true

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

# Switch to root so we can do root things
USER root

# Save the build arguments as a variable
ARG USER_ID
ARG GROUP_ID

# Use the build arguments to change the UID
# and GID of www-data while also changing
# the file permissions for NGINX
RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    # Update the file permissions for our NGINX service to match the new UID/GID
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

# Drop back to our unprivileged user
USER www-data

############################################
# Production Image
############################################

# Since we're calling "base", production isn't
# calling any of that permission stuff
FROM base AS production
ENV PHP_OPCACHE_ENABLE=1
# Copy our app files as www-data (33:33)
COPY --chown=www-data:www-data ./composer.json /var/www/html
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
#    --no-dev \
    --no-scripts \
    --ignore-platform-req=ext-http

COPY --chown=www-data:www-data . /var/www/html

