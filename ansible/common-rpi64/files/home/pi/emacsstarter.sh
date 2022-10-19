#!/bin/sh
##
## run emacs as daemon to keep workspace persistent and only connect via
## emacsclient to the permanently running daemon
##
## INSTALLATION
##
## # aptitude install emacsclient
##
## edit .bash_aliases
##   alias emacs='~/.emacsstarter.sh'
##
## and enable bash_aliases in .bashrc
##
## the first run will start the server
## $ emacs --daemon
##
## further calls for "emacs" will start clients on shell
## $ emacsclient -t
##
test -z "$(pidof emacs)" && emacs --daemon
emacsclient -t "$@"
