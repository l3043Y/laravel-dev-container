#!/bin/bash

cd /var/www/html || exit

echo "alias art=\"php artisan\"" >> ~/.profile
echo "source ~/.profile" >> ~/.bashrc

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
    barryvdh/laravel-ide-helper \
    laravel/telescope 

alias
