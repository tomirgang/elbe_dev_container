#!/bin/bash

IMAGE_PATH=$1

FULL_IMAGE_PATH=""
# find build result folder
if [[ "${IMAGE_PATH}" != "/"* ]]; then
    # handle relative path
    if [ ! -d "${IMAGE_PATH}" ]; then
        # relative path from current folder does not exist
        # use relative path in workspace images folder
        FULL_IMAGE_PATH="/build/workspace/result/images/${IMAGE_PATH}"
    else
        FULL_IMAGE_PATH=$(realpath ${IMAGE_PATH})
    fi
else
    FULL_IMAGE_PATH=${IMAGE_PATH}
fi

cd ${FULL_IMAGE_PATH}

qemu-system-aarch64 \
    -machine virt -cpu cortex-a72 -machine type=virt -nographic -m 4G \
    -netdev user,id=mynet0 \
    -device virtio-net-pci,netdev=mynet0 \
    -kernel vmlinuz \
    -append "console=ttyAMA0 root=LABEL=root" \
    -initrd initrd.img \
    sdcard.qcow2
