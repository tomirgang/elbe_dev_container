#!/bin/bash

if [ -z "${INITVM}" ]; then
        export INITVM="/build/init/vm"
fi

echo "Using initvm location ${INITVM}."

# check if initvm exists
FILE="${INITVM}/Makefile"
if [ ! -f "$FILE" ]; then

        echo "Initvm seems to not exist, starting initvm build."
        echo "Please be patient, this one time initialization may take more than 30 minutes."    

        pushd /build/elbe
        elbe_qinit create --devel
        RESULT=$?
        popd

        if [ $RESULT -ne 0 ]; then
                echo "ERROR: Creation of initvm failed!"
                exit 1
        else                
                # reset screen
                reset
                clear

                echo "SUCCESS: Elbe initvm successfully created!"

                elbe_stop
        fi
fi

cd ${INITVM}
make run_qemu
