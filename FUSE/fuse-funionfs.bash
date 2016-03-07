#!/usr/bin/env bash

userid=${UID:-$(id -u)}
grpid=${GID:-$(id -g)}

fu_name="Porn"
fu_mount=/run/user/${userid}/fuse/unionfs

fu_rodirs="/home/dubkat/Videos/Porn:/usr/local/home/dubkat/Porn"
fu_rwdirs="/run/user/${userid}/fuse/exfat/Backups/Video/Porn=rw"

if [ ! -d $fu_mount ]; then
	mkdir -p "${fu_mount}/${fu_name}"
	chown ${userid}:${grpid} "${fu_mount}/${fu_name}"
	echo "[Desktop Entry]" > "${fu_mount}/.desktop" 2>/dev/null || true
	echo "Icon=cpu" >> "${fu_mount}/.desktop" 2>/dev/null || true
fi


echo "Mounting $fu_rodirs $fu_rwdirs into $fu_mount"
funionfs none "${fu_mount}/${fu_name}" -o dirs="${fu_rodirs}:${fu_rwdirs}",allow_root,uid=${userid},gid=${grpid}
echo "[Desktop Entry]" > "${fu_mount}/${fu_name}/.desktop" 2>/dev/null || true
echo "Icon=cpu" >> "${fu_mount}/${fu_name}/.desktop" 2>/dev/null || true

exit $?

