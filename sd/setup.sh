#!/bin/sh -e
##
## provide e.g. /dev/sdh, when there is an /dev/sdh1 and /dev/sdh2
## e.g.
## $ ./setup.sh /dev/sdh UNIT01 10.1.10.33
##
## - provide rootfs secrets and modifyable data under "secret"
## - try to make sure you have sudo permissions

die()
{
	echo "FAILED! $@"
	exit 1
}

## 64-bit pi OS
IMG="$( ls ../downloads/*-arm64-lite.img )"

## 32-bit pi OS
#IMG="$( ls ../downloads/*-armhf-lite.img )"

if [ $# -lt 1 ]; then
	die "usage: ${0} <dev of SD card> [ <hostname> [ <static ip> ]]"
fi
DEV="$1"
test ! -e "$DEV" && die "'$DEV' does not exist!" || true

if [ $# -gt 1 ]; then
	HNAME="$2"
fi
echo "using hostname '$HNAME'"

if [ $# -eq 3 ]; then
	IPADDR="$3"
fi
echo "using ipaddr '$IPADDR'"

sudo dd if="$IMG" of="$DEV" bs=4M conv=fdatasync status=progress
sleep 5

## boot
BOOT="/media/$USER/bootfs"
udisksctl mount -b "${DEV}1"
## /boot [fat32] won't keep protections, which will throw an error -> true
sudo cp -arfv ./boot/* "$BOOT"/ || true
udisksctl unmount -b "${DEV}1"

## rootfs (fix networking for initial ssh connection via eth0)
ROOTFS="/media/$USER/rootfs"
udisksctl mount -b "${DEV}2"
sudo cp -arfv ./rootfs/* "$ROOTFS/"

## (1/2) secret: /etc configs
sed -i "/^127.0.1.1/s/.*/127.0.1.1           ${HNAME}/" ./secret/etc/hosts
echo "$HNAME" > ./secret/etc/hostname
if [ IPADDR != "" ]; then
	if [ -f ./secret/etc/dnsmasq.conf ]; then
		sed -i "/^listen-address=/s/.*/listen-address=::1,127.0.0.1,${IPADDR}/" ./secret/etc/dnsmasq.conf
	fi
	if [ -f ./secret/etc/NetworkManager/system-connections/eth0.nmconnection ]; then
		sed -i "/address1=/s/.*/address1=${IPADDR}\/24/" ./secret/etc/NetworkManager/system-connections/eth0.nmconnection
## FIXME: providing this connection file is not enough, a "wired connection 1" will overwrite this setting
		sed -i "/^iface eth0/s/.*/#iface eth0.../" ./secret/etc/network/interfaces
	else
		sed -i "/ *address /s/.*/    address ${IPADDR}/" ./secret/etc/network/interfaces
	fi
fi
sudo cp -arfv ./secret/etc "$ROOTFS/"

## (2/2) secret: ~/ configs
sudo cp -arfv ./secret/home/pi "$ROOTFS/home/"
sudo chown -R 1000:1000 "$ROOTFS/home/pi"
test -d "$ROOTFS/home/pi" && sudo chmod 700 "$ROOTFS/home/pi" || true
test -d "$ROOTFS/home/pi/.ssh" && chmod 700 "$ROOTFS/home/pi/.ssh" || true

## rootfs - remove dhcpcd (we use dnsmasq)
sudo rm -fv "$ROOTFS/etc/systemd/system/multi-user.target.wants/dhcpcd.service"

udisksctl unmount -b "${DEV}2"

echo "READY."
