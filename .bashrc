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

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

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


###################################
######## Useful functions #########
###################################

#function setHooks()
#{
#    if [ ! -f ~/.githooks/commit-msg ]; then
#        if [ ! -d ~/.githooks ]; then
#            mkdir ~/.githooks
#        fi
#        cd ~/.githooks
#        echo "Getting up-to-date git hooks..."
#        wget 10.10.1.61/commit-msg
#        chmod 755 ./commit-msg
#        cd -
#    fi
#    if [ -d /mnt/taykey ]; then
#        for dir in `ls /mnt/taykey -aR | grep ".git/hooks:" | awk -F: '{print $1"/"}'`
#        do
#            if [ ! -f $dir/commit-msg ]; then
#                echo "Linking git hooks in '$dir'"
#                ln -s ~/.githooks/commit-msg $dir/commit-msg
#            fi
#        done
#    fi
#}

#setHooks

function ask() # See 'killps' for example of use.
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
    *) return 1 ;;
esac
}

function f () { find -iname "$1" 2>/dev/null; }
function fd () { find "$1" -iname "$2" 2>/dev/null; }
function ff () { find . -type f | grep -v \' | xargs -I '{}' grep $1 '{}' -sl; }

# Allow remote connection (over SSH) to jmx beans
#function jc {
#host=$1
#proxy_port=${2:-8123}
#jconsole_host=tk-ubuntu02
#ssh -l ubuntu -i ~/.ssh/taykeyw.pem -f -D127.0.0.1:$proxy_port $host 'ssh -N' ssh_pid=`ps ax | grep "[s]sh -f -D127.0.0.1:$proxy_port" | awk '{print $1}'`
#jconsole -J-DsocksProxyHost=localhost -J-DsocksProxyPort=$proxy_port service:jmx:rmi:///jndi/rmi://${jconsole_host}:8181/jmxrmi
#kill $ssh_pid
#}

function xtitle() # Adds some text in the terminal frame.
{
    case "$TERM" in
        *term | rxvt)
            echo -n -e "\033]0;$*\007" ;;
        *)
            ;;
    esac
}

# .. and functions
function man()
{
    for i ; do
        xtitle The $(basename $1|tr -d .[:digit:]) manual
        command man -a "$i"
    done
}

function extract() # Handy Extract Program.
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xvjf $1 ;;
            *.tar.gz) tar xvzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) unrar x $1 ;;
             *.gz) gunzip $1 ;;
             *.tar) tar xvf $1 ;;
             *.tbz2) tar xvjf $1 ;;
             *.tgz) tar xvzf $1 ;;
             *.zip) unzip $1 ;;
             *.Z) uncompress $1 ;;
             *.7z) 7z x $1 ;;
             *) echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
 }

 function fawk {
 if [ -n "${2}" ]; then
     delim="-F \"${2}\""
 fi
 first="awk $delim '{print "
 last="}'"
 cmd="${first}\$${1}${last}"
 eval $cmd
}

function showLine {
cmd="cat \"${1}\" | awk 'NR==\"${2}\"'"
eval $cmd
}

function pipeShowLine {
cmd="awk 'NR==${1}'"
eval $cmd
}

# do sudo, or sudo the last command if no argument given
function s()
{
    if [[ $# == 0 ]]; then
        sudo $(history -p '!!')
    else
        sudo "$@"
    fi
}

# instead of typing 'cd ../..' write 'up 2'
function up()
{
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++))
    do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

if [ -f /usr/bin/pygmentize ]; then
    function cless
    {
        pygmentize $1 | less -R
    }
    alias cmore='cless'
fi

##################################
############ Aliases: ############
##################################

# Aliases that use xtitle
alias top='xtitle Processes on $HOST && top'
alias make='xtitle Making $(basename $PWD) ; make'
alias ncftp="xtitle ncFTP ; ncftp"

# Useful aliases
alias ks='killall -s 9 skype && skype &>/dev/null &'
alias kill_skype='ks'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -ahlF --group-directories-first'
alias la='ls -A'
alias l='ll -CFh'
alias lh='ls -h'
#alias tree='tree -Csu' # nice alternative to 'recursive ls'
alias tree="ls -R | grep ':$' | sed -e 's/:$//' -e 's/[^\/]*\//| /g' -e 's/| \([^|]\)/\`--\1/g'"
alias h='history'

function cg()
{
    cd ~/code/github/$1
}

function bgd()
{
    $1 &
    disown
}

alias curl='curl -H "Accept: application/octet-stream"'

alias ..='cd ..'
alias cd..='cd ..'

alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(\" \".join(sys.argv[1:]))"'
alias urldecode_pipe='python -c "
import sys, urllib as ul
line = sys.stdin.readline()
while line:
    print ul.unquote_plus(line)
    line=sys.stdin.readline()"
    '

    alias psa='ps -ax'

    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
    # -> Prevents accidentally clobbering files.
    alias mkdir='mkdir -p'

    alias h='history'
    alias j='jobs -l'

    alias sl='showLine'
    alias psl='pipeShowLine'

    alias path='echo -e ${PATH//:/\\n}'
    alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

    alias du='du -kh' # Makes a more readable output.
    alias df='df -kTh'

    # Add an "alert" alias for long running commands. Use like so:
    # sleep 10; alert
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

    alias gupd="ls -aR | grep \".git:\" | awk -F. '{ print \".\"\$2}' | xargs -L 1 bash -c 'cd \"\$1\" && git pull' _"

    alias su32='schroot -c percise_i386 -u root'
    alias ch32='schroot -c percise_i386 -u'

    cd

    fortune
