#!/bin/sh 
ARG=$1
GPIONUM=26
PID_GPIO="$(pgrep -fa gpioset | grep "gpiochip0 $GPIONUM=1" | awk '{ print $1 }')"
case "$ARG" in
        "start")
                ## turn on, if not already "running", else nothing
                test -z $PID_GPIO && /usr/bin/gpioset -m signal gpiochip0 $GPIONUM=1 &
                ;;
        "stop")
                ## turn off, if there was one "running"
                test ! -z $PID_GPIO && kill -15 $PID_GPIO
                /usr/bin/gpioset -m exit gpiochip0 $GPIONUM=0
                ;;
        *)
                echo "arg missing or wrong '$ARG'"
                ;;
esac
