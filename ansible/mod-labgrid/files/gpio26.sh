#!/bin/sh 
ARG=$1
case "$ARG" in
	"start")
		/usr/bin/gpioset -m wait gpiochip0 26=1
		;;
	"stop")
		/usr/bin/gpioset -m wait gpiochip0 26=0
		;;
	*)
		echo "arg missing or wrong '$ARG'"
		;;
esac
