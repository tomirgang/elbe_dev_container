#!/bin/bash

FILE=$(realpath $1)

NAME=$(basename $FILE)
FOLDER=$(dirname $FILE)

if [[ $NAME != CMakeLists.txt ]]; then
    echo "Please select the main CMakeLists.txt of the app."
    exit 1
fi

if [ ! -f "/var/cache/pbuilder/base.tgz" ]; then
    sudo pbuilder create
fi

cd $FOLDER

pdebuild
pdebuild -- --host-arch arm64
