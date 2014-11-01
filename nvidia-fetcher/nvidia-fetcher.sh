#!/bin/bash

#####
#    Nvidia Fetcher for Linux/FreeBSD 
#    Download and install the lastest propritary drivers for your nix.
#
#    Copyright (C) 2014  Dan Reidy <dubkat@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    $Id$
#####

#end of opts
nvidia_fetcher_version="0.1"

about="

    nVidia Fetcher for Linux/FreeBSD  Copyright (C) 2014  Dan Reidy <dubkat@gmail.com>
    This program comes with ABSOLUTELY NO WARRANTY; for details type $0 -a
    This is free software, and you are welcome to redistribute it
    under certain conditions.
    
"

# begin taking over the world
shift $((OPTIND-1));

# check only? fetch-udpate (assumes check), install, install-specific-version, about, help
#getopts cfiahv: options;

nv_check_latest_only=0
nv_fetch_specific_version=0
nv_version=0
nv_version_latest=0
nv_driver_name=""
nv_fetch_only=0
nv_install=0
nv_no_multilib=0
nv_show_about=0
nv_show_help=0

nv_kernel="`uname -s`"
nv_arch="`uname -i`"
nv_site="ftp://download.nvidia.com/XFree86/${nv_kernel}-${nv_arch}"

co_blue="\e[1;34m"
co_green="\e[1;32m"
co_grey="\e[1;30m"
co_red="\e[1;31m"
co_yellow="\e[1;33m"
co_magenta="\e[1;35m"
co_cyan="\e[1;36m"
co_white="\e[1;37m"
co_null="\e[0m"


# Functions
function show_about ()
{
	echo $about
	exit 0;
}

function nv_printhelp ()
{
	echo
	echo "$0	-a: print about"
	echo "$0	-c: check only the latest version number available"
	echo "$0	-d: check and download the latest version available only"
	echo "$0	-i: install (implies -c and -d)"
	echo "$0	-m: on 64bit machines, fetch the no-multilib version."
	echo "$0	-v <DRIVER VERSION>: download specific driver version."
	echo "$0	-h: print this help."
	echo
	echo "The simplest way to run this script is to issue the following command:"
	echo "$0 -i"
	echo
}

# ripped from Gentoo's functions.sh
# Copyright (c) 2007-2009 Roy Marples <roy@marples.name>
function yesno ()
{
    [ -z "$1" ] && return 1

    case "$1" in
        [Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1) 
        	return 0
        	;;
        [Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0) 
        	return 1
        	;;
    esac

    local value=
    eval value=\$${1}
    case "$value" in
        [Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1) return 0;;
        [Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0) return 1;;
        *) echo "\$$1 is not set properly"; return 1;;
    esac
}



function debug ()
{
	[ ! $nv_script_debug ] && return
	echo "$*" >&2
}

function nv_fetch ()
{
	src="$1"
	dest="$2"
	if [ ! -z $dest ]; 
	then
		curl --silent $src > $dest
		return $?
	else
		curl --silent $src
		return $?
	fi
	
	return 127
}

function nv_getLatestVerNo ()
{
	debug "fetching info from:  $nv_site/latest.txt"
	nv_version_latest="$(nv_fetch $nv_site/latest.txt | awk '{ print $1 }')"
	debug "Latest version from nvidia: $nv_version_latest"
}

function nv_checkPossibleVersion ()
{
	nv_fetch $nv_site/${nv_driver_name}.sha256 $nv_srcdir/${nv_driver_name}.sha256
	return $?
}



while getopts "acdihmuv:" options; do
	case $options in
		a)
			nv_show_about=1
			break;
    		;;
    	c)
    		nv_check_latest_only=1
    		break;
    		;;
    	d)
    		nv_fetch_only=1
    		;;
    	i)
    		nv_install=1
    		;;
    	h)
    		nv_show_help=1
    		;;
    	m)
    		nv_no_multilib=1;
    		;;
    	v)
    		nv_fetch_specific_version="$OPTARG"
    		;;
    	u)
    		nv_script_debug=1
    		;;
    	\?)
    		nv_printhelp
    		exit 127;
    	;;
	esac
done

nv_srcdir="/usr/src/NVIDIA"
if [ $UID -ne 0 ]; then
	nv_srcdir="${HOME}/NVIDIA"
fi

echo -e "${co_green}nVidia${co_null} ${co_white}Fetcher for $nv_kernel ($nv_arch) $nvidia_fetcher_version by Dan Reidy <dubkat@gmail.com>${co_null}"

if [ $# -eq 0 ]; then
	nv_printhelp
	exit 127;
fi

# get the latest version, it's used thoughout the script.
nv_getLatestVerNo;


if [ $nv_check_latest_only -eq 1 ];
then
	echo
	echo -e "The latest version for ${nv_kernel}/${nv_arch} is: ${co_white}$nv_version_latest ${co_null}"
	echo -e "To install this, issue ${co_white}$0 -i${co_null}"
	echo
	exit 0;
fi

if [ $nv_fetch_only -eq 1 ] || [ $nv_install -eq 1 ];
then
	if [ ! -d $nv_srcdir ];
	then
		echo "Nvidia Source Directory doesn't exist, creating it: ${nv_srcdir}" >&2
		mkdir -p ${nv_srcdir};
	fi
	
	# if no specified version, we want the latest
	if [ "$nv_fetch_specific_version" == "0" ];
	then
		nv_version="$nv_version_latest"
	else
		nv_version="$nv_fetch_specific_version"
		echo
		echo "You requested to fetch version: $nv_version"
		echo -n "Latest version is: $nv_version_latest, do you wish to continue? [yes/NO]: "
		resp=""
		while IFS= read -r -s -n1 cont; do
			if [[ -z $cont ]]; then
				echo; break;
			else
				echo -n $cont
				resp+=$cont
				
			fi
		done
		
		yesno $resp
		
		if [ $? -ne 0 ]; then
			debug "Response was no, exiting."
			exit 0;
		fi
	fi
	
	nv_driver_name="NVIDIA-${nv_kernel}-${nv_arch}-${nv_version}"
	if [ $nv_no_multilib -eq 1 ];
	then
		nv_driver_name="${nv_driver_name}-no-multilib"
	fi
	nv_driver_name="${nv_driver_name}.run"
	
	debug
	debug "wanted version: $nv_version"
	debug "driver: $nv_driver_name"
	debug
	
	# FIXME
	#if [ "$(nv_checkPossibleVersion)" == "0" ]; then
		#	echo "YES"
	#else
		#	echo "No"
	#fi
	
	nv_site="${nv_site}/${nv_version}"
	
	echo -e "${co_white}Fetching: 	 ${co_blue}${nv_driver_name}.sha256${co_null}"
	nv_fetch ${nv_site}/${nv_driver_name}.sha256 ${nv_srcdir}/${nv_driver_name}.sha256
	
	if [ ! -s ${nv_srcdir}/${nv_driver_name}.sha256 ]; then
		echo -e "${co_red}ERROR: 		${co_null} Unable to install $nv_driver_name. Likely invalid version." >&2
		rm -f ${nv_srcdir}/${nv_driver_name}.sha256
		exit 127;
	fi
	
	if [ -f "${nv_srcdir}/${nv_driver_name}" ]; then
		echo -e "${co_yellow}WARNING:${co_null} ${nv_srcdir}/${nv_driver_name} exists, backing up."
		
		mv "${nv_srcdir}/${nv_driver_name}" "${nv_srcdir}/${nv_driver_name}~"
	fi
	
	echo -e "${co_white}Fetching: 	 ${co_blue}${nv_driver_name}${co_null}"
	nv_fetch ${nv_site}/${nv_driver_name} ${nv_srcdir}/${nv_driver_name}
	
	if [ ! -s ${nv_srcdir}/${nv_driver_name} ]; then
		echo -e "${co_red}ERROR:	${co_null} ${nv_driver_name} has a zero filesize." >&2
		exit 127;
	fi
	debug "running sed on on sha256 file to use full pathname"
	sed -i ${nv_srcdir}/${nv_driver_name}.sha256 -e "s#NVIDIA-#${nv_srcdir}/NVIDIA-#"
	sha256sum -c ${nv_srcdir}/${nv_driver_name}.sha256
	
fi






