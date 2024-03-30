#!/bin/bash

FILE=$(realpath $1)

NAME=$(basename $FILE)
FOLDER=$(dirname $FILE)

if [[ $NAME != CMakeLists.txt ]]; then
    echo "Please select the main CMakeLists.txt of the app."
    exit 1
fi

project_build_app $folder
