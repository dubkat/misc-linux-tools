#!/bin/bash
userid=${UID:-$(id -u)}
grpid=${GID:-$(id -g)}


UUID="5601-DE85"
fu_name="Backups"


fu_mount=/run/user/${userid}/fuse/exfat

if [ -L /dev/disk/by-uuid/${UUID} ]; then
	mkdir -p "${fu_mount}/${fu_name}"
	sudo mount.exfat-fuse -o rw,uid=$userid,gid=$grpid $(realpath /dev/disk/by-uuid/${UUID}) "${fu_mount}/${fu_name}"
	exit $?
fi


