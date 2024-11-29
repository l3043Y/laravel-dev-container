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


composer require --ignore-platform-reqs --no-cache \
    l3043y/laravel-common \
    laravel/pulse \
    opcodesio/log-viewer \
    dedoc/scramble \
    spatie/laravel-health \
    spatie/laravel-data

composer require --dev \
    # laravel/telescope \
    barryvdh/laravel-ide-helper 

php artisan vendor:publish --tag=log-viewer-assets
# php artisan telescope:install
php artisan common:install
php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"
