#!/bin/bash

cd /var/www/html || exit
composer create-project laravel/laravel tmp
mv tmp/* .
mv tmp/.[!.]* .
rm -rf tmp
composer require --ignore-platform-reqs --no-cache \
    l3043y/laravel-common \
    laravel/pulse \
    opcodesio/log-viewer \
    dedoc/scramble \
    spatie/laravel-health \
    spatie/laravel-data

composer require --dev \
    laravel/telescope
