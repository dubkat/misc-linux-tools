#!/bin/sh
# Copyleft (7) 2016 Dan Reidy <dubkat@gmail.com>
# http://github.com/dubkat/misc-linux-tools

: ${NG_VERSION:=3.7}

: ${NG_HARDENED}

case $HARDENED in
	[Yy]|[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|1 )
		NG_HARDENED=".hardened"
		;;
	* )
		NG_HARDENED=""
		;;
esac
URL="https://raw.githubusercontent.com/gentoo/gentoo/master/app-admin/syslog-ng/files/${NG_VERSION}/syslog-ng.conf.gentoo${NG_HARDENED}"

echo "Fetching Gentoo Linux's syslog-ng.conf ..."
if hash wget 2>/dev/null; then
	wget $URL -O `pwd`/syslog-ng${NG_HARDENED}.conf
else
	curl $URL -o `pwd`/syslog-ng${NG_HARDENED}.conf
fi
exit $?

