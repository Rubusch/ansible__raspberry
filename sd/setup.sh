#!/bin/sh -e
##
## provide e.g. /dev/sdh, when there is an /dev/sdh1 and /dev/sdh2
## e.g.
## $ ./setup.sh /dev/sdh place01 10.1.10.33
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

if [ $# -ne 3 ]; then
	die "usage: ${0} <dev of SD card> [ <hostname> [ <static ip> ]]"
fi
DEV="$1"
test ! -e "$DEV" && die "'$DEV' does not exist!" || true

HNAME="$2"
echo "using hostname '$HNAME'"

IPADDR="$3"
echo "using ipaddr '$IPADDR'"

sudo dd if="$IMG" of="$DEV" bs=4M conv=fdatasync status=progress
sleep 5

## boot
BOOT="/run/media/$USER/bootfs"
udisksctl mount -b "${DEV}1"
## /boot [fat32] won't keep protections, which will throw an error -> true
sudo cp -arfv ./boot/* "$BOOT"/ || true
udisksctl unmount -b "${DEV}1"

## rootfs (fix networking for initial ssh connection via eth0)
ROOTFS="/run/media/$USER/rootfs"
udisksctl mount -b "${DEV}2"
sudo cp -arfv ./rootfs/* "$ROOTFS/"

## secret: /etc configs
sudo cp -arfv ../secret/* "$ROOTFS/"
sudo sed -i "/^127.0.1.1/s/.*/127.0.1.1           ${HNAME}/" $ROOTFS/etc/hosts
echo "$HNAME" | sudo tee $ROOTFS/etc/hostname
if [ IPADDR != "" ]; then
	if [ -f $ROOTFS/etc/dnsmasq.conf ]; then
		sudo sed -i "/^listen-address=/s/.*/listen-address=::1,127.0.0.1,${IPADDR}/" $ROOTFS/etc/dnsmasq.conf
	fi
	if [ -f $ROOTFS/etc/NetworkManager/system-connections/eth0.nmconnection ]; then
		sudo sed -i "/address1=/s/.*/address1=${IPADDR}\/24/" $ROOTFS/etc/NetworkManager/system-connections/eth0.nmconnection
		sudo chown root:root $ROOTFS/etc/NetworkManager/system-connections/eth0.nmconnection
		sudo chmod 600 $ROOTFS/etc/NetworkManager/system-connections/eth0.nmconnection
	else
		sudo sed -i "/ *address /s/.*/    address ${IPADDR}/" $ROOTFS/etc/network/interfaces
	fi
fi
sudo chown -R 1000:1000 "$ROOTFS/home/pi"
test -d "$ROOTFS/home/pi" && sudo chmod 700 "$ROOTFS/home/pi" || true
test -d "$ROOTFS/home/pi/.ssh" && chmod 700 "$ROOTFS/home/pi/.ssh" || true

## rootfs - remove dhcpcd (we use dnsmasq)
sudo rm -fv "$ROOTFS/etc/systemd/system/multi-user.target.wants/dhcpcd.service"
udisksctl unmount -b "${DEV}2"
echo "READY."
