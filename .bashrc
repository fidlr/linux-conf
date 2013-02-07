# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

###################################
######## General settings #########
###################################

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

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
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
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
    PS1_TEMP=$PS1
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    PS1_TEMP=$PS1
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    
    function title() {
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)} $@ \a\]$PS1_TEMP"
    }
    
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1_TEMP"
    ;;
*)
    ;;
esac

###################################
###### Environment variables ######
###################################

export HOST=`hostname`

if [ -d /usr/local/apache-maven/apache-maven-3.0.4 ]; then
    export M2_HOME=/usr/local/apache-maven/apache-maven-3.0.4
    export M2=$M2_HOME/bin
elif [ -d /usr/local/maven-3.0.3 ]; then
    export M2_HOME=/usr/local/maven-3.0.3/
elif [ -d /usr/local/maven ]; then
        export M2_HOME=/usr/local/maven/
fi

# Adding bin of hadoop related projects to path
if [ -d /usr/local/hadoop ]; then
    export PATH="$PATH":/usr/local/hadoop/bin:/usr/local/hbase/bin:/usr/local/hive/bin:.
    export HADOOP_HOME=/usr/local/hadoop
    export PATH="$PATH:$HADOOP_HOME/bin:."
fi

# HBase binaries
if [ -d /usr/local/hbase ]; then
    export PATH="$PATH:/usr/local/hbase/bin"
fi

# HIVE binaries
if [ -d /usr/local/hive ]; then
    export PATH="$PATH:/usr/local/hive/bin"
fi

# MONO stuff
if [ -d /usr/lib/mono ]; then
    export MONO_PATH=/usr/lib/mono/
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=5000
HISTFILESIZE=20000

export AMZ_MACHINES=/mnt/x/RnD/Hadoop/Amazon\ Machines.txt

if [ -f ~/.pystartup ]; then
    export PYTHONSTARTUP=~/.pystartup
fi

###################################
######## Useful functions #########
###################################

function svnaddu() {
    FILES=`svnunv`
    echo $FILES
    if ask "Add these files to subversion?"
            then svnunv | xargs svn add
    fi
}

function svnrmu() {
    FILES=`svnunv`
    echo $FILES
    if ask "Delete these files?"
            then svnunv | xargs rm -rv
    fi
}

function ask()          # See 'killps' for example of use.
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function svnunv() {
    FILES=`svn status | grep \? | awk '{print $2}'`
    echo $FILES
}

function svnrm() {
    FILES=`svnmissing`
    echo $FILES
    if ask "Delete these files?"
            then svnmissing | xargs svn rm
    fi
}

function svnmissing() {
    FILES=`svn status | grep \! | awk '{print $2}'`
    echo $FILES
}


function f () { find -iname "$1" 2>/dev/null; }
function fd () { find "$1" -iname "$2" 2>/dev/null; }
function ff () { find / -iname $1 2>/dev/null; }

# Allow remote connection (over SSH) to jmx beans
function jc {
    host=$1
    proxy_port=${2:-8123}
    jconsole_host=tk-ubuntu02
    ssh -l ubuntu -i ~/.ssh/taykeyw.pem -f -D127.0.0.1:$proxy_port $host 'ssh -N' ssh_pid=`ps ax | grep "[s]sh -f -D127.0.0.1:$proxy_port" | awk '{print $1}'`
    jconsole -J-DsocksProxyHost=localhost -J-DsocksProxyPort=$proxy_port service:jmx:rmi:///jndi/rmi://${jconsole_host}:8181/jmxrmi
    kill $ssh_pid
}

# Create hosts file with the help of amazon machins text file
function create_hosts {
    N=0
    echo "
    Adding the following NS redirections:
    "
    echo "

    # Added by automatic script" >> /etc/hosts
    cat "$AMZ_MACHINES" | grep -v -i "user\|password" | while read LINE ; do
        if [[ "$LINE" == *[a-zA-Z0-9]* ]];
        then
            N=$((N+1))
            isEvenNo=$( expr $N % 2 )
            if [ $isEvenNo -ne 0 ];
            then
                # even match
                MACHINE=`echo "$LINE" | tr -d '\n' | tr -d '\r' | awk -F\- '{ print $1 }' | awk '{ printf tolower($1); for (i=2;i<=NF;i++) printf "_%s",tolower($i); print "" }'`
                COMMENT=`echo "$LINE" | tr "#" "-" | tr -d '\n' | tr -d '\r'`
                #echo "    PC: $MACHINE"
            else
                # odd match
                LOCATION=`echo "$LINE" | awk '{ print $2 }' | tr -d '\n' | tr -d '\r'`
                IP=`echo $LOCATION | awk -F\- '{ if (NF >= 2) print $2 "." $3 "." $4 "." $5; else print $1; }' | awk -F\. '{ print $1 "." $2 "." $3 "." $4 }'`
                INPUT=`echo "$IP z_$MACHINE #$LOCATION" | tr -d '\n' | tr -d '\r'`
                EXISTS=`cat /etc/hosts | grep "$INPUT"`
                if [ -z "$EXISTS" ];
                then
                    echo " +  $INPUT"
                    echo "#    $COMMENT" >> /etc/hosts                    
                    echo "$INPUT" >> /etc/hosts
                    echo "" >> /etc/hosts
                else
                    echo "->  $MACHINE ($COMMENT) already exists"
                fi
            fi
        fi
    done
    echo
    echo "    # End of automatic script additions
" >> /etc/hosts
}

function xtitle()      # Adds some text in the terminal frame.
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

function extract()      # Handy Extract Program.
{
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1     ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1      ;;
             *.rar)       unrar x $1      ;;
             *.gz)        gunzip $1       ;;
             *.tar)       tar xvf $1      ;;
             *.tbz2)      tar xvjf $1     ;;
             *.tgz)       tar xvzf $1     ;;
             *.zip)       unzip $1        ;;
             *.Z)         uncompress $1   ;;
             *.7z)        7z x $1         ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

function fawk {
    first="awk '{print "
    last="}'"
    cmd="${first}\$${1}${last}"
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
alias c_hosts='sudo bash -ic "create_hosts"'

if [ -d /mnt/taykey/dev ]; then
    alias taykey='cd /mnt/taykey/dev/'
fi

if [ -f ~/.svn-ignore.log ]; then
    alias svnignore='svn propset svn:ignore -F ~/.svn-ignore.log ./'
fi

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
alias tree='tree -Csu'     # nice alternative to 'recursive ls'
function fif() { find . -type f | grep -v \' | xargs -I '{}' grep -i $1 '{}' -sl; }

alias ..='cd ..'
alias cd..='cd ..'

alias curlh='curl -H "Accept: application/octet-stream"'
alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(\" \".join(sys.argv[1:]))"'
alias urldecode_pipe='python -c "import sys, urllib as ul;
    line = sys.stdin.readline();
    while line:
        print ul.unquote_plus(line);
        line=sys.stdin.readline();"'
alias urldecode_pipe2='python -c "import sys, urllib as ul; print  ul.unquote_plus(\" \".join([l for l in sys.stdin.readlines()]))"'


alias psa='ps -ax'
alias svnup='svn update'
alias svnst='svn status'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# -> Prevents accidentally clobbering files.
alias mkdir='mkdir -p'

alias h='history'
alias j='jobs -l'

alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'       # Makes a more readable output.
alias df='df -kTh'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Taykey SSH
if [ -f ~/.ssh/taykeyw.pem ]; then
    alias sshl='ssh -i ~/.ssh/taykeyw.pem -l ubuntu'
    alias scpl='scp -i ~/.ssh/taykeyw.pem -rv'

    # Remote connection (SSH) to amazon's machines
    alias ssh_dashboard='sshl z_dashboard'
    alias ssh_facebook='sshl z_fb_agent'
    alias ssh_master='sshl z_hadoop_master'
    alias ssh_slave1='sshl z_hadoop_slave1'
    alias ssh_slave2='sshl z_hadoop_slave2'
    alias ssh_slave3='sshl z_hadoop_slave3'
    alias ssh_slave4='sshl z_hadoop_slave4'
    alias ssh_test1='sshl z_itay_test'
    alias ssh_test2='sshl z_itay_test2'
    #alias ssh_monitor='sshl z_tkapp1'
    #alias ssh_control='monitor_ssh'
    #alias ssh_lbq='monitor_ssh'
    #alias ssh_minerva='sshl z_tkapp2'
    #alias ssh_minerva1='minerva_ssh'
    #alias ssh_agents1='sshl z_tkapp3'
    #alias ssh_agents2='sshl z_tkapp4'
    #alias ssh_checkers='sshl z_tkapp5'
    alias ssh_dbservice='sshl z_tkapp6'
    alias ssh_backends='sshl z_tkapp7'
    #alias ssh_minerva2='sshl z_tkapp8'
    alias ssh_trendster='sshl z_trendster'
    #alias ssh_nagios='sshl z_nagios_server'
    alias ssh_socks='ssh -D 6666 -i ~/.ssh/taykeyw.pem -g ubuntu@z_hadoop_master -N &'
fi

# Taykey related useful aliases
alias amazon='cat "$AMZ_MACHINES"'
alias amazong='gedit "$AMZ_MACHINES"'
#alias amazon='cat /mnt/x/Users/Everybody/Avihoo/ec2/Amazon\ Machines.txt'
#alias amazong='gedit /mnt/x/Users/Everybody/Avihoo/ec2/Amazon\ Machines.txt'
# some more ls aliases
export MONO_PATH='/usr/lib/mono'
export REPO='https://tk001/svn/Taykey'
#export M2_HOME='/home/omer/maven'
export JAVA_HOME='/usr/lib/jvm/java-6-sun'
export ORACLE_HOME=/usr/lib/oracle/11.2/client
export ANDROID_HOME=/home/omer/apps/android-sdks
export PATH="$PATH:$M2_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"

function cless {
        pygmentize $1 | less -R
	}

alias cmore='cless'

# Taykey HQ's Hadoop related aliases
if [ -d /usr/local/hadoop ]; then
    alias hadoop_start='/usr/local/hadoop/bin/start-all.sh'
    alias hadoop_stop='/usr/local/hadoop/bin/stop-all.sh'
fi

if [ -d /usr/local/hbase ]; then
    alias hbase_start='/usr/local/hbase/bin/start-hbase.sh'
    alias hbase_stop='/usr/local/hbase/bin/stop-hbase.sh'
fi

source /usr/local/bin/virtualenvwrapper.sh
