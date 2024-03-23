#!/bin/bash

export PATH=$PATH:/build/scripts:/build/elbe

WORKSPACE_BIN="/workspace/bin"
if [ -d "${WORKSPACE_BIN}" ]; then
    export PATH=$PATH:$WORKSPACE_BIN
fi

# and soruce berrymill venv
source /build/venv/bin/activate
