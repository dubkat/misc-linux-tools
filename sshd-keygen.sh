#!/usr/bin/env bash

# we do nothing unless told explicit.

function usage() {
	echo
	echo "$0 : [/path/to/etc/ssh] [hostname]"
	for x in `seq 0 ${#0}`; do echo -n " "; done
	echo ": Both these options should be auto detected, should not be required."
	for x in `seq 0 ${#0}`; do echo -n " "; done
	echo ": Copyleft(L) 2013-2015 Dan Reidy "
	for x in `seq 0 ${#0}`; do echo -n " "; done
	echo ": <dubkat+github@gmail.com> http://goo.gl/GW3dZS"
	echo ""
}
 
while getopts ":h?M:H:P:k:b" opt; do
  case $opt in
    M)
		_moduli="${OPTARG}"
		;;
	H)
		_hostname="${OPTARG}"
		;;
	P)
		_confdir="${OPTARG}"
		;;
	k)
		_keytype="${OPTARG}"
		;;
	b)
		_bits="${OPTARG}"
		;;

    \?|h)
      usage
	  exit 0;
      ;;
  esac
done

_dryrun="${_dryrun:-1}"
_moduli="${moduli:-4096}"
_hostname="${_hostname:-${HOSTNAME}}"
_confdir="${_confdir:-/etc/ssh}"
_keytype="${_keytype:-ecdsa}"
_bits="${_bits:-4096}"


echo "Setting config directory to: ${_confdir}"
echo "     Overriding hostname to: ${_hostname}"
echo "           moduli is set to: ${_moduli}"
echo "                    keytype: ${_keytype}"
echo "                   key bits: ${_bits}"

exit 0

