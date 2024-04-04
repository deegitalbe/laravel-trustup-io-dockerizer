#!/bin/bash

secret() {
  doppler secrets download \
      --project "$1" \
      --config local \
      --no-file \
      --format env | grep -Ev 'DOPPLER|NUXT' \
    >> .env
}

append() {
  echo $1=\"$2\" >> .env
}

true > .env && \
secret "trustup-io-app-commons" && \
secret "{{{{appKey}}}}" && \
append UID $(id -u) && \
append GID $(id -g)