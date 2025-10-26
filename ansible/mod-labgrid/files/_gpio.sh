#!/bin/sh 
ARG=$1
GPIONUM=$(echo $0 | awk '{match($0, /[[:digit:]]+/); s = substr($0, RSTART, RLENGTH); print s}')

die() { echo $@; exit 0; }

test -z ${GPIONUM} && die "wrong GPIO number '$GPIONUM'"

PID_GPIO="$(pgrep -fa gpioset | awk "/gpiochip0 $GPIONUM=1/{split(\$0, a, /[[:blank:]]/); print a[1]}" | xargs)"
case "$ARG" in
        "start")
                ## turn on, if not already "running", else nothing
                test -z "$PID_GPIO" && /usr/bin/gpioset -m signal gpiochip0 $GPIONUM=1 &
                ;;
        "stop")
                ## turn off, if there was one "running"
                test ! -z "$PID_GPIO" && kill -15 $PID_GPIO
                /usr/bin/gpioset -m exit gpiochip0 $GPIONUM=0
                ;;
        *)
                echo "arg missing or wrong '$ARG'"
                ;;
esac
