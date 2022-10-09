#!/bin/sh -e
##
## provide e.g. /dev/sdi, when there is an /dev/sdi1 and /dev/sdi2
##
## - provide rootfs secrets under "secrets"
## - try to make sure you have sudo permissions

DEV="${1}"
IMG="./download/2022-09-22-raspios-bullseye-arm64-lite.img"

if [ -z "${DEV}" ]; then
	echo "usage: ${0} <dev of SD card>"
	exit 1
fi

sudo dd if="${IMG}" of="${DEV}" bs=4M conv=fdatasync status=progress
sleep 5

udisksctl mount -b "${DEV}1"
sudo cp -arf ./rootfs/boot/* /media/${USER}/boot/
udisksctl unmount -b "${DEV}1"

udisksctl mount -b "${DEV}2"
sudo cp -arf ./rootfs/etc /media/${USER}/rootfs/
sudo cp -arf ./rootfs/root /media/${USER}/rootfs/
cp -arf ./rootfs/home/pi /media/${USER}/rootfs/home/

sudo cp -arf ./secret/etc /media/${USER}/rootfs/
cp -arf ./secret/home/pi /media/${USER}/rootfs/home/
udisksctl unmount -b "${DEV}2"

echo "READY."

