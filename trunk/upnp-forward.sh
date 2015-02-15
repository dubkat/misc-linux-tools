#!/bin/bash
#
# upnp-forward.sh - Easily forward requested ports from a UPnP capable router using upnpc.
# Copyright (C) 2014-2015 Dan Reidy <dubkat@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# See the GNU General Public License for more details.
#
# $Id$

INTERFACE="wlo1"
PORTS_TCP="22 16881"
PORTS_UDP="16881 17881 18881"


### End of settings ###


lanip="`ip addr show ${INTERFACE} | grep -vE '127.0|::1' | grep 'inet ' | awk '{ print $2 }' | cut -d/ -f1`"

function upnp_start()
{
	for port in ${PORTS_TCP}; do
		upnpc -a $lanip $port $port TCP
	done
	for port in ${PORTS_UDP}; do
		upnpc -a $lanip $port $port UDP
	done
	echo "* Don't forget to open ports tcp($PORTS_TCP), udp($PORTS_UDP) in your system firewall."
}


function upnp_stop()
{
	for port in ${PORTS_TCP}; do
		upnpc -d $port TCP
	done
	for port in ${PORTS_UDP}; do
		upnpc -d $port UDP
	done
	echo "* Don't forget to close ports tcp($PORTS_TCP), udp($PORTS_UDP) in your system firewall."

}

function upnp_status()
{

	upnpc -m $lanip -l | egrep '^\s[i0-9]' | column -t
}

case $1 in

	start )
		upnp_start;
		;;
	stop )
		upnp_stop;
		;;

	reset|restart )
		upnp_stop;
		upnp_start;
		;;

	status )
		upnp_status;
		;;

	* )
		echo "${0}: Unknown Command. Commands are 'start' or 'stop' or 'reset'."
		exit 1;
		;;
esac









