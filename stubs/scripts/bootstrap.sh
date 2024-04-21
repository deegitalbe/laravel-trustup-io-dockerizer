#!/bin/bash

./scripts/set_env.sh && \
ENV=local VERSION=local USER_ID=$(id -u) GROUP_ID=$(id -u) make build && \
docker compose run --rm --no-deps \
    {{{{appKey}}}}-cli \
    sh -c "composer install && bun install && bun run build" && \
./cli start && \
sleep 10 && \
./cli artisan migrate && \
./cli stop
