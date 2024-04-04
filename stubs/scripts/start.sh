#!/bin/bash

./scripts/set_env.sh && \
./scripts/dependencies.sh start && \
docker compose up -d
