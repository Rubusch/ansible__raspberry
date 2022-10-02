# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

## full history hack
unset HISTFILESIZE
HISTSIZE=10000000
PROMPT_COMMAND="history -a"
export HISTSIZE PROMPT_COMMAND
shopt -s histappend

## check the window size after each command and, if necessary,
## update the values of LINES and COLUMNS.
shopt -s checkwinsize

## make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

## set a fancy prompt (non-color, unless we know we "want" color)
#case "$TERM" in
#xterm-color)
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#    ;;
#*)
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#    ;;
#esac

## Comment in the above and uncomment this below for a color prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\h<\[\033[01;32m\]\t\[\033[00;32m\]>::\[\033[01;32m\]\u\[\033[00;32m\]("\[\033[01;32m\]\w/\[\033[00;32m\]");\e[0m\n\$ '
PS1='${debian_chroot:+($debian_chroot)}\[\033[00;95m\]\h<\[\033[01;95m\]\t\[\033[00;95m\]>::\[\033[01;95m\]\u\[\033[00;95m\]("\[\033[01;95m\]\w/\[\033[00;95m\]");\e[0m\n\$ '

## If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

## enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
fi

## some more ls aliases
alias ll='ls -l'
alias la='ls -al'
alias l='ls -CF'

## Some more alias to avoid making mistakes:
#alias rm='rm -fv'
#alias cp='cp -v'
#alias mv='mv -v'
#alias du='du -h'
#alias df='df -h'
alias diff='colordiff'
alias top='htop'
#alias emacs='emacs21 -nw'

## windows aliases
alias cd..='cd ..'

## grep colors
alias grep='grep --color'


# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

## to avoid blank on kernel console - do this from console:
#setterm -blank 0

## emacs server
echo "aliasing 'emacs' to '.emacsstarter.sh'"
alias emacs='~/.emacsstarter.sh'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

echo "setting EDITOR"
export EDITOR=/usr/bin/vim

#export INTELFPGAOCLSDKROOT="/opt/intelFPGA/18.1std/hld"
#export QSYS_ROOTDIR="/opt/intelFPGA/18.1std/quartus/sopc_builder/bin"

echo "setting SYSTEMD_EDITOR"
export SYSTEMD_EDITOR=vim
. "$HOME/.cargo/env"
