#!/bin/bash

ID=$1
shift

if ! [[ $ID =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 <number 1-254>"
    exit 1
fi

BASE_IMG=rooter-base.img
IMG=rooter${ID}.img
TAP=vtap${ID}
MAC=c8:5b:76:fd:3f:$(printf %02x $ID)
NAME=rooter${ID}
MEM=512
BRIDGE=br0
BIOS=/usr/share/ovmf/ovmf_code_x64.bin


if ! [[ -e "$IMG" ]]; then
    qemu-img create -f qcow2 -b "$BASE_IMG" "$IMG"
fi


sudo ip tuntap add mode tap user damjan name ${TAP}
sudo ip link set up dev ${TAP} master ${BRIDGE}


qemu-system-x86_64 -enable-kvm -m $MEM                                                                          \
    -name "$NAME"                                                                                               \
    -bios "$BIOS"                                                                                               \
    -device virtio-scsi-pci,id=scsi0,bus=pci.0,addr=0x6                                                         \
    -device scsi-hd,bus=scsi0.0,channel=0,scsi-id=0,lun=0,drive=drive-scsi0-0-0-0,id=scsi0-0-0-0,bootindex=1    \
    -drive file="$IMG",format=qcow2,if=none,id=drive-scsi0-0-0-0,discard=unmap                                  \
                                                                                                                \
    -netdev user,id=net0,hostname="$NAME",net=10.${ID}.2.0/24,dhcpstart=10.${ID}.2.15                           \
    -device virtio-net,netdev=net0                                                                              \
                                                                                                                \
    -netdev tap,id=net1,ifname=${TAP},script=no,downscript=no                                                   \
    -device virtio-net,netdev=net1,mac=${MAC}



sudo ip tuntap del mode tap name ${TAP}


# to trim the image file: qemu-img convert -O qcow2 <old image> <new image>
