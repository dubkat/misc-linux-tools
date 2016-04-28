#!/usr/bin/env bash
#
# syshead.sh - Print a useful, dynamic MOTD on user login.
# Copyright (C) 2014-2016 Dan Reidy <dubkat@gmail.com>, http://plus.google.com/+DanReidy
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
ULE_WELCOME_VERSION=16.04.24
#
# Version: 2016031500
#
#Updates can be downloaded from GitHub!
# https://raw.githubusercontent.com/dubkat/misc-linux-tools/master/system-motd.sh
#

# if you live in the EU, you may want to change this to 'whois.ripe.net'
whois_server="whois.arin.net"
# other options include ip.appspot.com
external_ip_src="http://ifconfig.co"

# no figlet header.
no_fig_header="0"

# display this text file as header
# useful for custom logo, etc
# no_fig_header must be 1
custom_header_file="/etc/leaf"


[[ -z $PS1 ]] || return

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

sys_vendor="$(</sys/class/dmi/id/sys_vendor)"
sys_product="$(</sys/class/dmi/id/product_name)"
sys_chassis="$(hostnamectl | grep -i chassis | awk -F: '{ print $NF }' | xargs)"
if [ $sys_chassis = "vm" ]; then
  sys_vendor="${sys_product}";
  sys_product=""
fi

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
co_bold=""

function debug ()
{
  if [ ! -z $syshead_debug ]; then
    echo "$*"
  fi
}

function _mac_detect ()
{
  if [ -e "/usr/bin/sw_vers" ]; then
    is_mac=1;
    return
  fi
  fig_default_opts="${fig_default_opts} -t"
}

function _is_admin ()
{
  for group in `groups`; do
    if [ "$group" = "admin" ] || [ "$group" = "wheel" ]; then
      echo -n "Y"
      return
    fi
  done
  echo -n "N"
  return
}

function _activate_color ()
{
  # text format && color
  #ORN=$(tput setaf 3); RED=$(tput setaf 1); BLU=$(tput setaf 4)
  #GRN=$(tput setaf 40); MGN=$(tput setaf 5); CLR=$(tput sgr0)
  local colorsize=0
  if hash tput >/dev/null 2>&1; then
    colorsize=$(tput colors)
  fi

  test $colorsize -gt 0 || return;

  if [ $colorsize -eq 256 ]; then
    co_bold="$(tput bold)";
    co_red="$(tput setaf 160)";
    co_green="$(tput setaf 28)";
    co_yellow="$(tput setaf 106)";
    co_blue="$(tput setaf 27)";
    co_magenta="$(tput setaf 200)";
    co_cyan="$(tput setaf 87)";
    co_white="$(tput setaf 231)";
    co_black=$(tput setaf 240);
    co_null="$(tput sgr0)";

  else
    co_bold="$(tput bold)";
    co_red="$(tput setaf 001)";
    co_green="$(tput setaf 002)";
    co_yellow="$(tput setaf 003)";
    co_blue="$(tput setaf 004)";
    co_magenta="$(tput setaf 005)";
    co_cyan="$(tput setaf 006)";
    co_white="$(tput setaf 007)";
    co_black=$(tput setaf 000);
    co_null="$(tput sgr0)";
  fi

  return
}



# MACHINE-INFO
PRETTY_HOSTNAME=
LOCATION="<unknown>"
DEPLOYMENT="standard"

hide_v4_if_nat=0

# the figfont "term"
sm_font="term"

# the big header font to use...
# if we have toilet installed, use this font...
toilet_big_font="pagga"
figlet_big_font="shadow"

# message too long fix
if [ "${TERM}" = "dumb" ]; then
  return
  #message="Dumb Term, Exiting.:${message}"
  #fatal=$[fatal +1]
fi


if ! hash figlet >/dev/null 2>&1; then
  message="Figlet is not installed.:${message}"
  message="Toilet is also recommended.:${message}"
  fatal=$[fatal +1]
fi


if ! hash whois >/dev/null 2>&1; then
  message="Whois is not installed.:${message}"
  fatal=$[fatal +1]
fi

if ! hash finger >/dev/null 2>&1; then
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


_activate_color

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

hostname_short=""
hostname_fqdn=""

if hash hostnamectl >/dev/null 2>&1; then
  hostname_short="`hostnamectl --pretty`"
  hostname_fqdn="`hostnamectl --static`"
else
  hostname_short="`hostname -s`"
  hostname_fqdn="`hostname -f`"
fi

if [ $havenet ]; then
  debug "have a network, testing..."
  IPv4="$(curl --connect-timeout 5 -f -s -4 ${external_ip_src})"
  IPv6="$(curl --connect-timeout 5 -f -s -6 ${external_ip_src})"

  if [ ! -z $IPv4 ]; then
    net4name="`whois -h ${whois_server:-whois.arin.net} $IPv4 | grep OrgName | awk -F": +" '{ print $2 }'`"
  fi
  if [ ! -z $IPv6 ]; then
    net6name="`whois $IPv6 | grep OrgName | awk -F": +" '{ print $2 }'`"
  fi
  #echo "ipv4: $IPv4"
  #echo "net4: $net4name"
fi

debug "* checking uptime."
LOAD="`uptime | awk -F": " '{ print $2 }'`"
UPTIME="`uptime | cut -d, -f1 | sed 's/.*up *//'`"

debug "* checking usercount"
USERCOUNT="`who | awk '{ print $1 }' | sort | uniq | wc -l | xargs`"

debug "begin output.."
if [ $no_fig_header -eq 0 ]; then
  echo -e ${co_default}
  if hash toilet >/dev/null 2>&1; then
    figlet ${fig_default_opts} $center -f $toilet_big_font $hostname_short
  else
    figlet ${fig_default_opts} $center -f $figlet_big_font $hostname_short
  fi
elif [ $no_fig_header -eq 1 ] && [ -f $custom_header_file ]; then
  cat $custom_header_file
  echo -e ${co_default}
fi 
figlet ${fig_default_opts} $center -f $sm_font $hostname_fqdn 
figlet ${fig_default_opts} $center -f $sm_font $PRETTY_NAME 
figlet ${fig_default_opts} $center -f $sm_font "`uname -s` `uname -r` (`uname -m`)" 
figlet ${fig_default_opts} $center -f $sm_font Hardware: ${sys_vendor} ${sys_product} 
figlet ${fig_default_opts} $center -f $sm_font Chassis: ${sys_chassis}


if [ $is_mac -eq 0 ]; then
  figlet ${fig_default_opts} $center -f $sm_font Entropy: $(</proc/sys/kernel/random/entropy_avail) / $(</proc/sys/kernel/random/poolsize)
fi

figlet ${fig_default_opts} $center -f $sm_font Users: $USERCOUNT users online. \($LOAD\)
figlet ${fig_default_opts} $center -f $sm_font System Online: $UPTIME
if [ ! -z "$LOCATION" ]; then
  figlet ${fig_default_opts} $center -f $sm_font Location: $LOCATION
fi

echo -e ${co_null}
echo

if [ $havenet ]; then

  debug "* have a network, so printing IP addresses."
  figlet ${fig_default_opts} $center -f $sm_font My Public IP Addresses

  echo -en ${co_default}
  figlet ${fig_default_opts} $center -f $sm_font -- "--------------------------"
  echo -en ${co_null}

  echo -en ${co_green}
  figlet ${fig_default_opts} $center -f $sm_font ${IPv4}
  echo -en ${co_black}
  figlet ${fig_default_opts} $center -f $sm_font $net4name
  echo -en ${co_null}
  echo

  if [ ! -z $IPv6 ]; then
    debug "* have ipv6, so printing IPv6 addresss."
    echo -en ${co_magenta}
    figlet ${fig_default_opts} $center -f $sm_font $IPv6
    echo -en ${co_black}
    figlet ${fig_default_opts} $center -f $sm_font $net6name
    echo -en ${co_default}
  fi
fi

echo

realname="`finger $USER | grep Name | awk -F'Name: ' '{ print $2 }'`"

echo

if [ $is_mac -eq 1 ]; then
  echo Current Memory: $(top -d -l 1 | grep PhysMem | awk -F: '{ print $2 }' | xargs)
fi

# enable this if you want, but can take a long time to process large home directories.
#HOME_SIZE="`du -hs $HOME | awk '{ print $1 }'`"

if [ ! -z $HOME_SIZE ]; then
  echo -e Your home directory is ${co_magenta}$HOME${co_null} and consumes ${co_red}${HOME_SIZE}${co_null} of space.
fi

echo The date is $(date "+%A, %B %d %Y %Z")
echo It is currently $(date "+%r")

if [ "$(_is_admin)" = "Y" ]; then
  echo -e "Welcome ${co_bold}Jedi Master${co_null} ${realname}. May the Force be with you."
else
  echo "Welcome ${realname}."
fi

debug "* im done, peace out."
