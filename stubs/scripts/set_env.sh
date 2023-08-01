#!/bin/bash

true > .env && \
doppler secrets download \
  --project "trustup-io-app-commons" \
  --config local \
  --no-file \
  --format env | grep -v '^DOPPLER_' \
  >> .env && \
doppler secrets download \
  --project "{{{{appKey}}}}" \
  --config local \
  --no-file \
  --format env | grep -v '^DOPPLER_' \
  >> .env