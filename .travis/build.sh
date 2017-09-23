#!/usr/bin/env bash

set -e

docker build -t infolinks/loggly-sidecar:${TRAVIS_COMMIT} .

if [[ ${TRAVIS_TAG} =~ ^v[0-9]+$ ]]; then
    docker tag infolinks/loggly-sidecar:${TRAVIS_COMMIT} infolinks/loggly-sidecar:${TRAVIS_TAG}
    docker push infolinks/loggly-sidecar:${TRAVIS_TAG}
    docker tag infolinks/loggly-sidecar:${TRAVIS_COMMIT} infolinks/loggly-sidecar:latest
    docker push infolinks/loggly-sidecar:latest
fi
