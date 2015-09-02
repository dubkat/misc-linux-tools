#!/usr/bin/env bash
#
# syshead.sh - Print a useful, dynamic MOTD on user login.
# Copyright (C) 2014-2015 Dan Reidy <dubkat@gmail.com>, http://plus.google.com/+DanReidy
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#################################################################################
#
# Version: 2015070200
# It is expected that this file is sourced when the profile is loading during 
# user login, and not run directly.
#
# We are not an interactive shell, there's no point in continuing.
echo "\$- = $-"
[[ $- =~ "i" ]] || exit $?

# variables used in script, not settngs.
fatal=0;
is_mac=0;
message="";
fig_default_opts=" -k"
IPv4=""
IPv6=""
net4name="Unknown."
net6name="Unknown."
havenet=0;
center=" -c "
left=" -l "
right=" -r "

# color code holder
co_blue=""
co_green=""
co_grey=""
co_red=""
co_yellow=""
co_magenta=""
co_cyan=""
co_white=""
co_null=""
co_default=""

function debug
{
    if [ ! -z $syshead_debug ]; then
        echo "$*"
    fi
}

function _mac_detect
{
	if [ -e "/usr/bin/sw_vers" ]; then
		is_mac=1;
		return
	fi
	fig_default_opts="${fig_default_opts} -t"
}

function _is_admin
{
  local val=$(groups | grep -cE '\bwheel\b|\badmin\b');
  if [ $val -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

function _activate_color
{
	# text format && color
	#ORN=$(tput setaf 3); RED=$(tput setaf 1); BLU=$(tput setaf 4)
	#GRN=$(tput setaf 40); MGN=$(tput setaf 5); CLR=$(tput sgr0)


	co_blue="\e[0;34m"
	co_green="\e[0;32m"
	co_grey="\e[0;30m"
	co_red="\e[0;31m"
	co_yellow="\e[0;33m"
	co_magenta="\e[0;35m"
	co_cyan="\e[0;36m"
	co_white="\e[0;37m"
	co_null="\e[0m"
}



# MACHINE-INFO
PRETTY_HOSTNAME=
LOCATION="<unknown>"
DEPLOYMENT="standard"

hide_v4_if_nat=0

# the figfont "term"
sm_font="term"

# the big header font to use...
big_font="shadow"

# message too long fix
case "${TERM}" in
    *rxvt* ) ;;
    screen ) ;;
    xterm* ) ;;
    *color* ) ;;
    linux ) 
	_active_color
	;;

    * )

    ;;
esac

# message too long fix
if [ "${TERM}" = "dumb" ]; then
    message="Dumb Term, Exiting.:${message}"
    fatal=$[fatal +1]
fi


if [ ! -x `which figlet` ]; then
    message="Figlet is not installed.:${message}"
    fatal=$[fatal +1]
fi


if [ ! -x `which whois` ]; then
    message="Whois is not installed.:${message}"
    fatal=$[fatal +1]
fi

if [ ! -x `which finger` ]; then
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

# the following file is on systemd powered systems
if [ -e "/etc/machine-info" ]; then
    . /etc/machine-info 2>/dev/null
fi

if [ -e "/etc/os-release" ]; then
    . /etc/os-release 2>&1 >/dev/null
    if [ ! -z $ANSI_COLOR ]; then
        co_default="\e[${ANSI_COLOR}m"
    fi
else
    _mac_detect
    if [ $is_mac ]; then
	PRETTY_NAME="`sw_vers -productName` `sw_vers -productVersion`"
	co_default="${co_blue}"
    else
	PRETTY_NAME="`uname -s` `uname -r` (`uname -m`)"
	co_default="\e[${co_cyan}"
    fi
fi

hostname_short="<unknown>"
hostname_fqdn="unknown.example.org"

if [ ! -x `which hostnamectl >/dev/null 2>&1` ]; then
    hostname_short="`hostnamectl --short`"
    hostname_fqdn="`hostnamectl --long`"
else
    hostname_short="`hostname -s`"
    hostname_fqdn="`hostname -f`"
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
    IPv4="$(curl --connect-timeout 10 -f -s -4 http://ip.appspot.com)"
    IPv6="$(curl --connect-timeout 10 -f -s -6 http://ip.appspot.com)"
    if [ ! -z $IPv4 ]; then
        net4name="`whois $IPv4 | grep OrgName | awk -F": +" '{ print $2 }'`"
    fi
    if [ ! -z $IPv6 ]; then
        net6name="`whois $IPv6 | grep OrgName | awk -F": +" '{ print $2 }'`"
    fi
fi

debug "* checking uptime."
LOAD="`uptime | awk -F": " '{ print $2 }'`"
UPTIME="`uptime | cut -d, -f1 | sed 's/.*up *//'`"

debug "* checking usercount"
USERCOUNT="`who | awk '{ print $1 }' | sort | uniq | wc -l | xargs`"

debug "begin output.."
echo -e ${co_default}
figlet ${fig_default_opts} $center -f $big_font $hostname_short
figlet ${fig_default_opts} $center -f $sm_font $hostname_fqdn
figlet ${fig_default_opts} $center -f $sm_font $PRETTY_NAME
figlet ${fig_default_opts} $center -f $sm_font "`uname -s` `uname -r` (`uname -m`)"


if [ $is_mac -eq 0 ]; then
    figlet ${fig_default_opts} $center -f $sm_font Entropy $(</proc/sys/kernel/random/entropy_avail) / $(</proc/sys/kernel/random/poolsize)
fi

figlet ${fig_default_opts} $center -f $sm_font $USERCOUNT users online. \($LOAD\)
figlet ${fig_default_opts} $center -f $sm_font System Online: $UPTIME
if [ ! -z "$LOCATION" ]; then
    figlet ${fig_default_opts} $center -f $sm_font Location: $LOCATION
fi

echo -e ${co_null}
echo

if [ $havenet ]; then
    have_ip="`/sbin/ifconfig | grep '$IPv4' | wc -l | xargs`"

    debug "* have a network, so printing IP addresses."
    figlet ${fig_default_opts} $center -f $sm_font My Public IP Addresses

    echo -en ${co_default}
    figlet ${fig_default_opts} $center -f $sm_font -- "--------------------------"
    echo -en ${co_null}

    if [ ! $hide_v4_if_nat ] && [ $have_ip ]; then
	figlet ${fig_default_opts} $center -f $sm_font $IPv4
	figlet ${fig_default_opts} $center -f $sm_font \($net4name\)
	echo
    fi

    if [ ! -z $IPv6 ]; then
        debug "* have ipv6, so printing IPv6 addresss."
	echo -en ${co_magenta}
        figlet ${fig_default_opts} $center -f $sm_font $IPv6
	echo -en ${co_null}
        figlet ${fig_default_opts} $center -f $sm_font \($net6name\)
    fi
fi

echo

realname="`finger $USER | grep Name | awk -F'Name: ' '{ print $2 }'`"

echo

if [ $is_mac -eq 1 ]; then
    echo Current Memory: $(top -d -l 1 | grep PhysMem | awk -F: '{ print $2 }' | xargs)
fi

HOME_SIZE="`du -hs $HOME | awk '{ print $1 }'`"

echo -e Your home directory is ${co_magenta}$HOME${co_null} and consumes ${co_red}${HOME_SIZE}${co_null} of space.

echo The date is $(date "+%A, %B %d %Y %Z")
echo It is currently $(date "+%r")
echo -n Welcome ${realname}.
if [ _is_admin ]; then
    echo -e " You are a ${co_red}GOD${co_null}."
else
    echo
fi

debug "* im done, peace out."
