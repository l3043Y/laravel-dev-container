############################################
# Base Image
############################################
FROM serversideup/php:8.3-fpm-nginx-bookworm AS base
USER root

RUN install-php-extensions intl xsl bcmath
USER www-data

############################################
# Init Project
############################################
FROM base AS init-project
USER root


ARG USER_ID
ARG GROUP_ID


RUN docker-php-serversideup-set-id www-data $USER_ID:$GROUP_ID && \
    \
    docker-php-serversideup-set-file-permissions --owner $USER_ID:$GROUP_ID --service nginx

COPY --chown=www-data:www-data docker/scripts/init-laravel.sh /etc/entrypoint.d/0-init-laravel.sh
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

# Copy our app files as www-data (33:33)
COPY --chown=www-data:www-data . /var/www/html
