#!/bin/bash

if [ -z "${INITVM}" ]; then
        export INITVM="/build/init/vm"
fi

# check if initvm exists
if [ ! -f "${INITVM}/Makefile" ]; then

        echo "Initvm seems to not exist, starting initvm build."
        echo "Please be patient, this one time initialization may take more than 30 minutes."    

        elbe_qinit create --devel
        RESULT=$?

        if [ $RESULT -ne 0 ]; then
                echo "ERROR: Creation of initvm failed!"
                exit 1
        else                
                # reset screen
                reset
                clear

                echo "SUCCESS: Elbe initvm successfully created!"
                exit 0
        fi
fi

# start elbe initvm
elbe_qinit start
RESULT=$?

if [ $RESULT -ne 0 ]; then
        echo "ERROR: Start of elbe initvm failed!"
fi
