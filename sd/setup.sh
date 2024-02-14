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
## /boot [fat32] won't keep protections, which will throw an error -> true
sudo cp -arfv ./boot/* "${BOOT}"/ || true
udisksctl unmount -b "${DEV}1"

## rootfs (fix networking for initial ssh connection via eth0)
ROOTFS="/media/${USER}/rootfs"
udisksctl mount -b "${DEV}2"
sudo cp -arfv ./rootfs/* "${ROOTFS}/"

## (1/2) secret: /etc configs
sudo cp -arfv ./secret/etc "${ROOTFS}/"

## (2/2) secret: ~/ configs
sudo cp -arfv ./secret/home/pi "${ROOTFS}/home/"
sudo chown -R 1000:1000 "${ROOTFS}/home/pi"
test -d "${ROOTFS}/home/pi" && sudo chmod 700 "${ROOTFS}/home/pi" || true
test -d "${ROOTFS}/home/pi/.ssh" && chmod 700 "${ROOTFS}/home/pi/.ssh" || true

## rootfs - remove dhcpcd (we use dnsmasq)
sudo rm -fv "${ROOTFS}/etc/systemd/system/multi-user.target.wants/dhcpcd.service"

udisksctl unmount -b "${DEV}2"

echo "READY."
