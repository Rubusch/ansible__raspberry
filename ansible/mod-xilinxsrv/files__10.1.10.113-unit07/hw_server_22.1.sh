#!/usr/bin/bash
#
# start: start qemu hw_server
# stop: stop qemu hw_server
SERVERIP="10.1.10.113"
XILINX_VERSION="2022.1"

ARG=$1
case "$ARG" in
"start")
	test -f /run/hw_server.pid && exit 1
	test -z $( mount | grep "/x86/proc" ) && mount -t proc /proc /x86/proc || true
	test -z $( mount | grep "/x86/sys" ) && mount -t sysfs /sys /x86/sys || true
	test -z $( mount | grep "/x86/dev" ) && mount -o bind /dev /x86/dev || true
	test -z $( mount | grep "/x86/dev/pts" ) && mount -t devpts /dev/pts /x86/dev/pts || true
	echo $$ > /run/hw_server.pid
	chroot /x86 qemu-x86_64-static /usr/bin/bash -c "source /xilinx/Vivado_Lab/${XILINX_VERSION}/settings64.sh ; hw_server -s tcp:${SERVERIP}:3121"
	## the above shall not return, if it fails remove the pid file
	rm -f /run/hw_server.pid || true
	;;
"stop")
	test -f /run/hw_server.pid && kill $(cat /run/hw_server.pid) || true
	rm -f /run/hw_server.pid || true
	umount /x86/dev/pts || true
	umount /x86/dev || true
	umount /x86/sys || true
	umount /x86/proc || true
	;;
"debug")
	test -z $( mount | grep "/x86/proc" ) && mount -t proc /proc /x86/proc
	test -z $( mount | grep "/x86/sys" ) && mount -t sysfs /sys /x86/sys
	test -z $( mount | grep "/x86/dev" ) && mount -o bind /dev /x86/dev
	test -z $( mount | grep "/x86/dev/pts" ) && mount -t devpts /dev/pts /x86/dev/pts
	chroot /x86 qemu-x86_64-static /usr/bin/bash -c "source /xilinx/Vivado_Lab/${XILINX_VERSION}/settings64.sh ; hw_server -L/var/hw_server.log -lprotocol -s tcp:${SERVERIP}:3121"
	;;
*)
	echo "FAILED"
	;;
esac
echo "READY."
