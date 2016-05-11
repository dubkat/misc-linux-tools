#!/usr/bin/env bash
# Copyright (C) 2013-2016 Dan Reidy <dubkat@gmail.com>
# download a blocklist for pdnsd, load it, and go.
# License: GPLv2

REMOTE_LIST="http://pgl.yoyo.org/adservers/serverlist.php?hostformat=pdnsd&showintro=1&startdate%5Bday%5D=&startdate%5Bmonth%5D=&startdate%5Byear%5D=&mimetype=plaintext"

PDNS_CONF_DIR="/opt/local/etc/pdnsd"

# do we make pdns reload (useless otherwise)
PDNSD_RELOAD=1

SAVE="${PDNS_CONF_DIR%/}/trackers-`date --iso`.conf"

wget -O "${SAVE}" "${REMOTE_LIST}" || { echo "Failed to fetch remote file." >&2; exit 1 }

ln -s -f "${SAVE}" "${PDNS_CONF_DIR}/trackers-current.conf" || { echo "Failed to link $SAVE with trackers-current.conf" >&2; exit 1 }

if [ $PDNSD_RELOAD ]; then
	pdnsd-ctl config
fi

