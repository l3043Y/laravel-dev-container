#!/bin/bash

cd /var/www/html || exit

composer create-project laravel/laravel tmp
mv tmp/* .
mv tmp/.[!.]* .
rm -rf tmp

cp -r docker/templates/laravel/routes/* routes
cp -r docker/templates/laravel/Controllers/* app/Http/Controllers
cp -r docker/templates/laravel/Middlewares app/Http
cp -r docker/templates/laravel/Requests app/Http
cp -r docker/templates/laravel/Services app

sed -i '/web:/a\        api: __DIR__."/../routes/api.php",' bootstrap/app.php
sed -i '/->withMiddleware(function (Middleware $middleware) {/,/})/s|//|$middleware->api(append:[\\App\\Http\\Middlewares\\ForceJsonResponse::class]);|' bootstrap/app.php

# Define the new values
export NEW_DB_CONNECTION=pgsql
export NEW_DB_HOST=postgres
export NEW_DB_PORT="5432"
export NEW_DB_DATABASE="new_database"
export NEW_DB_USERNAME="new_user"
export NEW_DB_PASSWORD="new_password"

# Uncomment and update the lines in .env
sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=${NEW_DB_CONNECTION}/" .env
sed -i 's/^# DB_HOST=.*/DB_HOST='"${NEW_DB_HOST}"'/' .env
sed -i 's/^# DB_PORT=.*/DB_PORT='"${NEW_DB_PORT}"'/' .env
sed -i 's/^# DB_DATABASE=.*/DB_DATABASE='"${NEW_DB_DATABASE}"'/' .env
sed -i 's/^# DB_USERNAME=.*/DB_USERNAME='"${NEW_DB_USERNAME}"'/' .env
sed -i 's/^# DB_PASSWORD=.*/DB_PASSWORD='"${NEW_DB_PASSWORD}"'/' .env

composer require --ignore-platform-reqs --no-cache \
    l3043y/laravel-common \
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
