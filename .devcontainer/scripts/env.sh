#!/bin/bash

export PATH=$PATH:/build/scripts:/build/elbe

WORKSPACE_BIN="/workspace/bin"
if [ -d "${WORKSPACE_BIN}" ]; then
    export PATH=$PATH:$WORKSPACE_BIN
fi

# and soruce berrymill venv
source /build/venv/bin/activate

MAINTAINER="/build/identity/maintainer.sh"
if [ -f "/build/identity/maintainer.sh" ]; then
    source $MAINTAINER
fi

GNUPGHOME="/build/identity/.gnupg"
if [ -d "${GNUPGHOME}" ]; then
    overlay_mount "${GNUPGHOME}"
    export GNUPGHOME="/tmp/${GNUPGHOME}"
    echo "GnuPG home: ${GNUPGHOME}"
fi
