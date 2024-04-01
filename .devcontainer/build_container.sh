#!/bin/bash

CREATE_DATE="$(date)"
CREATE_COMMIT="$(git rev-parse HEAD)"
HOST_USER="${UID}"
HOST_GROUP=1000
KVM_GID="$(getent group kvm  | cut -d: -f3)"

echo "Create date: $CREATE_DATE"
echo "Create commit: $CREATE_COMMIT"
echo "Host UID: $HOST_USER"
echo "Host GID: $HOST_GROUP"
echo "Host UID: $KVM_GID"
echo "PWD: $PWD"

SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}")
echo "SCRIPT: $SCRIPT_DIR"
cd $SCRIPT_DIR

docker build \
    -f Dockerfile \
    --build-arg CREATE_DATE="$CREATE_DATE" \
    --build-arg CREATE_COMMIT="$CREATE_COMMIT" \
    --build-arg HOST_USER="$HOST_USER" \
    --build-arg HOST_GROUP="$HOST_GROUP" \
    --build-arg KVM_GID="$KVM_GID" \
    -t elbe_bookworm:latest .
