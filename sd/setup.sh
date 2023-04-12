#!/bin/sh -e
##
## provide e.g. /dev/sdi, when there is an /dev/sdi1 and /dev/sdi2
##
## - provide rootfs secrets under "secrets"
## - try to make sure you have sudo permissions

DEV="${1}"

## 64-bit pi OS
IMG="$( ls ./download/*-arm64-lite.img )"

## 32-bit pi OS
#IMG="$( ls ./download/*-armhf-lite.img )"

if [ -z "${DEV}" ]; then
	echo "usage: ${0} <dev of SD card>"
	exit 1
fi

sudo dd if="${IMG}" of="${DEV}" bs=4M conv=fdatasync status=progress
sleep 5


## boot
BOOT="/media/${USER}/bootfs"
udisksctl mount -b "${DEV}1"
sudo cp -arfv ./rootfs/boot/* "${BOOT}"/
udisksctl unmount -b "${DEV}1"


## rootfs (fix networking for initial ssh connection via eth0)
ROOTFS="/media/${USER}/rootfs"
udisksctl mount -b "${DEV}2"
sudo cp -arfv ./rootfs/etc "${ROOTFS}/"

sudo cp -arfv ./secret/etc "${ROOTFS}/"
sudo cp -arfv ./secret/home/pi "${ROOTFS}/home/"

## rootfs - remove dhcpcd (we use dnsmasq)
sudo rm -fv "${ROOTFS}/etc/systemd/system/multi-user.target.wants/dhcpcd.service"

udisksctl unmount -b "${DEV}2"

echo "READY."
