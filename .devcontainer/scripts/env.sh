#!/bin/bash

export PATH=$PATH:/build/scripts:/build/elbe

WORKSPACE_SCRIPTS="/workspace/scripts"
if [ -d "${WORKSPACE_SCRIPTS}" ]; then
    export PATH=$PATH:$WORKSPACE_SCRIPTS
fi

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
