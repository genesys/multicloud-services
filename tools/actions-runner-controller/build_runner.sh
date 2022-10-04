#!/bin/bash

# Provide your docker repository & image name
# as RUNNER_IMAGE here in code,
# or by "export RUNNER_IMAGE=..." in shell prior to running script

# Also provide credentials for your private repository
# as JFROG_USER and RUNNER_IMAGE variables

[[ ! "$STAG" ]] && STAG=latest
[[ ! "$RUNNER_IMAGE" ]] && export RUNNER_IMAGE=pureengage-docker-staging.jfrog.io/cpe/arc-runner

echo "Build runner image for Action-runner-controller"

echo "Trying login to registry"
docker login -u $JFROG_USER -p $JFROG_TOKEN pureengage-docker-staging.jfrog.io

echo "Checking if this version already exists"
if $( docker manifest inspect $RUNNER_IMAGE:$STAG > /dev/null ); then
    echo "ERROR: image with this tag: $RUNNER_IMAGE:$STAG - is already present in registry
            Delete it manually prior to build/push"
    exit 1
fi

echo "Building the image based on Dockerfile"
docker build --progress=plain . -t $RUNNER_IMAGE:$STAG

echo "Successfully built image, let's push it to registry"
docker push $RUNNER_IMAGE:$STAG
