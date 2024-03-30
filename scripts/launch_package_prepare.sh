#!/bin/bash

FILE=$(realpath $1)

NAME=$(basename $FILE)
FOLDER=$(dirname $FILE)

if [[ $NAME != CMakeLists.txt ]]; then
    echo "Please select the main CMakeLists.txt of the app."
    exit 1
fi

echo "Please provide the package name: "
read PACKAGENAME

echo "Please provide the package version: "
read PACKAGEVERSION

echo "Preparing app package ${PACKAGENAME}-${PACKAGEVERSION}."

package_prepare $FOLDER $PACKAGENAME $PACKAGEVERSION

echo "App package prepared in results/packages/${PACKAGENAME}-${PACKAGEVERSION}."
