#!/bin/bash

# no settings, just run it.

function debug
{
    if [ ! -z $syshead_debug ]; then
        echo "$*"
    fi
}

# variables used in script, not settngs.
fatal=0;
message="";
fig_default_opts="-t -k"
IPv4=""
IPv6=""
net4name="Unknown."
net6name="Unknown."
havenet=0;
center=" -c "
left=" -l "
right=" -r "

co_blue="\e[1;34m"
co_green="\e[1;32m"
co_grey="\e[1;30m"
co_red="\e[1;31m"
co_yellow="\e[1;33m"
co_magenta="\e[1;35m"
co_cyan="\e[1;36m"
co_white="\e[1;37m"
co_null="\e[0m"
co_default=""


# the figfont "term"
sm_font="term"

# the big header font to use...
big_font="shadow"

# message too long fix
case "${TERM}" in
    urxvt|rxvt-unicode* ) ;;
    screen ) ;;
    xterm* ) ;;

    linux )
        echo "Running from a console, how quaint."
    ;;

    * )
        message="Running from a $TERM is not supported here."
        fatal=$[fatal + 1]
    ;;
esac

# message too long fix
if [ "${TERM}" = "dumb" ]; then
    message="Dumb Term, Exiting.:${message}"
    fatal=$[fatal +1]
fi

if [ ! -x /usr/bin/figlet ]; then
    message="Figlet is not installed.:${message}"
    fatal=$[fatal +1]
fi

if [ ! -x /usr/bin/whois ]; then
    message="Whois is not installed.:${message}"
    fatal=$[fatal +1]
fi

if [ ! -x /usr/bin/finger ]; then
    message="Finger is not installed.:${message}"
    fatal=$[fatal +1]
fi

if [ $fatal -gt 0 ]; then
    echo "There are $fatal fatal errors."
    echo
    echo "**"
    echo "* $message" | sed -e 's/:/\n* /g'
    echo
    exit $fatal
fi

center=" -c "
left=" -l "
right=" -r "

if [ -e "/etc/os-release" ]; then
    . /etc/os-release 2>&1 >/dev/null
    if [ ! -z $ANSI_COLOR ]; then
        co_default="\e[\e${ANSI_COLOR}m"
    fi
else
    PRETTY_NAME="`uname -o` `uname -r` (`uname -v`)"
    co_default="${co_cyan}"
fi

debug "checking if i want full output, or short..."
if [ ! -z $syshead_full ] && [ "x${syshead_full}" != "xyes" ]; then
    debug "  * printing full output."
    netstatus=`nm-online -q`

    if [ "$netstatus" == "0" ]; then
        if [ $(ping -c1 8.8.8.8 &>/dev/null ) ]; then 
            havenet=1
        else
            havenet=0
        fi
    elif [ "$netstatus" == "1" ]; then
        message="Network is not currently connected."
        havenet=0
    elif [ "$netstatus" == "2" ]; then
        message="Network is in an unknown state."
        havenet=0
    fi
else
    debug "   * printing short output."
fi

if [ $havenet ]; then
    debug "have a network, testing..."
    IPv4="$(curl --connect-timeout 5 -s -4 ip.appspot.com)"
    IPv6="$(curl --connect-timeout 5 -s -6 ip.appspot.com)"
    if [ ! -z $IPv4 ]; then
        net4name="`whois $IPv4 | grep OrgName | awk -F": +" '{ print $2 }'`"
    fi
    if [ ! -z $IPv6 ]; then
        net6name="`whois $IPv6 | grep OrgName | awk -F": +" '{ print $2 }'`"
    fi
fi

debug "* checking uptime."
LOAD="`uptime | awk -F": " '{ print $2 }'`"

debug "* checking usercount"
USERCOUNT="`who | awk '{ print $1 }' | sort -h | wc -l`"

debug "begin output.."
echo -e ${co_default}
figlet ${fig_default_opts} $center -f $big_font $(hostname)
figlet ${fig_default_opts} $center -f $sm_font $(hostname).$(domainname)
figlet ${fig_default_opts} $center -f $sm_font $PRETTY_NAME
figlet ${fig_default_opts} $center -f $sm_font `uname -s` `uname -r`
figlet ${fig_default_opts} $center -f $sm_font Entropy $(</proc/sys/kernel/random/entropy_avail) / $(</proc/sys/kernel/random/poolsize)
figlet ${fig_default_opts} $center -f $sm_font $USERCOUNT users online. \($LOAD\)
echo -e ${co_null}
echo

if [ $havenet ]; then
    debug "* have a network, so printing IP addresses."
    figlet ${fig_default_opts} $center -f $sm_font My Public IP Addresses
    figlet ${fig_default_opts} $center -f $sm_font -- "--------------------------"
    figlet ${fig_default_opts} $center -f $sm_font $IPv4 
    figlet ${fig_default_opts} $center -f $sm_font \($net4name\)
    if [ ! -z $IPv6 ]; then
        debug "* have ipv6, so printing IPv6 addresss."
        echo
        figlet ${fig_default_opts} $center -f $sm_font $IPv6 
        figlet ${fig_default_opts} $center -f $sm_font \($net6name\)
    fi
fi

echo
debug "* printing group info."
figlet ${fig_default_opts} $center -f $sm_font Your Groups
figlet ${fig_default_opts} $center -f $sm_font -- "--------------"
figlet ${fig_default_opts} $center -f $sm_font `groups`



myfile=$(mktemp /dev/shm/syshead-${USER}-XXXX);
debug "* creating temporary file: $myfile."
# /usr/bin/df -hTP | grep ^dubkat | ccze
mcount="`df -a | grep ^$USER | wc -l`"
debug "* user $USER has $mcount personal mounts"

realname="`finger $USER | grep Name | awk -F'Name: ' '{ print $2 }'`"


#if [ "$EUID" != "0" ] && [ $mcount -gt 0 ]; then

#    echo; echo;
#    #echo "You currently have personal mountspace."
#    #echo "The following informational lines explain mountpoint and space used."
#    echo "Mount:Size:Used:Avail:Percent Used" > $myfile
#    /usr/bin/df -hTPa | grep ^$USER |  awk '{ printf "%s:%s:%s:%s:%s\n", $7, $3, $4, $5, $6 }' >> $myfile
#    cat $myfile | column -s: -t
#    echo; echo;
#
#else
    if [ $EUID -eq 0 ]; then
    #    echo "Mount:Size:Used:Avail:Percent Used" > $myfile
        /usr/bin/df -hTP -x tmpfs | awk '{ printf "%s:%s:%s:%s:%s\n", $7, $3, $4, $5, $6 }' >> $myfile
        cat $myfile | column -s: -t
    fi
#fi

unlink $myfile
echo
echo "Welcome ${realname}."
echo "`date`"
#echo "%RED%Welcome %BOLD%%WHITE%${realname}%NORM%" #| sed  \
#    -e 's/%RED%/\x1b[\[0;34m;/'  \
#    -e 's/%BOLD%/\x1b[\[1;00m;/'  \
#    -e 's/%WHITE%/\x1b[\[0;32m;/' \
#    -e 's/%NORM%/\x1b[\[0;00m;/'  

debug "* im done, peace out."
