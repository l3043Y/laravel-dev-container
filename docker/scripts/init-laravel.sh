#!/bin/bash

cd /var/www/html || exit

target_dir="init-sequence-tmp"

cd /var/www/html || exit

if [ -d "$target_dir" ]; then
  rm -rf "$target_dir"
fi

composer create-project laravel/laravel "$target_dir"
mv "$target_dir"/README.md "$target_dir"/LARAVEL_README.md
mv "$target_dir"/* .
mv "$target_dir"/.[!.]* .
rm -rf "$target_dir"

cat docker/scripts/example.env >> .env

#cp -r docker/templates/laravel/routes/* routes
#cp -r docker/templates/laravel/Controllers/* app/Http/Controllers
#cp -r docker/templates/laravel/Middlewares app/Http
#cp -r docker/templates/laravel/Requests app/Http
#cp -r docker/templates/laravel/Services app
#
#sed -i '/web:/a\        api: __DIR__."/../routes/api.php",' bootstrap/app.php
#sed -i '/->withMiddleware(function (Middleware $middleware) {/,/})/s|//|$middleware->api(append:[\\App\\Http\\Middlewares\\ForceJsonResponse::class]);|' bootstrap/app.php

# Uncomment and update the lines in .env
# source .env
sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=${DB_CONNECTION}/" .env
sed -i 's/^# DB_HOST=.*/DB_HOST='"${DB_HOST}"'/' .env
sed -i 's/^# DB_PORT=.*/DB_PORT='"${DB_PORT}"'/' .env
sed -i 's/^# DB_DATABASE=.*/DB_DATABASE='"${DB_DATABASE}"'/' .env
sed -i 's/^# DB_USERNAME=.*/DB_USERNAME='"${DB_USERNAME}"'/' .env
sed -i 's/^# DB_PASSWORD=.*/DB_PASSWORD='"${DB_PASSWORD}"'/' .env

composer require --no-cache \
#    l3043y/laravel-common \
    laravel/pulse \
    opcodesio/log-viewer \
    dedoc/scramble \
    spatie/laravel-health \
    spatie/laravel-data

# composer require --dev \
#     laravel/telescope \
#     barryvdh/laravel-ide-helper

php artisan vendor:publish --tag=log-viewer-assets
# php artisan telescope:install
php artisan common:install
php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"
