#!/bin/bash

./scripts/set_env.sh && \
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/var/www/html" \
    -w /var/www/html \
    laravelsail/php82-composer:latest \
    composer install --ignore-platform-reqs && \
./vendor/bin/sail build --no-cache && \
./cli start && \
./cli yarn install && \
./cli yarn build && \
./cli stop
