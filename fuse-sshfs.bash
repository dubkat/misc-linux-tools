#!/usr/bin/env bash

base="${XDG_RUNTIME_DIR}/fuse/sshfs"

green="$(tput setaf 2)"
red="$(tput setaf 1)"
default="$(tput op)"


function doMount {
	hosts="$(grep sshfs /etc/hosts | awk '{ print $2 }')"
	for host in $hosts; do
		if [ $gnu_sed ]; then
			volname="$(echo $host | sed 's/^./\U&/')"
		else
			volname="${host/.*/}"
		fi
		if [ ! -d "$base/$volname" ]; then
			mkdir -p "$base/$volname" || { echo "Failed to create mount point: $base/$volname." >&2 ; exit 1; }
		fi
		
		premount="`mount | grep "$base/$volname" | awk '{ print $3 }'`"
		if [ "x${premount}" != "x" ]; then
			echo "Pre-Existing Mount: $volname. Skipping."
			continue
		fi

		if [ ! `ssh $host "uptime" >/dev/null 2>&1` ]; then
			echo -n "Mounting volume $volname... "
			if [ -e /usr/bin/sw_vers ]; then
				command sshfs -o follow_symlinks,transform_symlinks,fsname=sshfs,idmap=user,volname="$volname" ${host}: ${base}/${volname} >/dev/null 2>&1
			else
				command sshfs -o follow_symlinks,transform_symlinks,fsname=sshfs,idmap=user ${host}: ${base}/${volname} >/dev/null 2>&1
			fi
			if [ "$?" = "0" ]; then
				echo -e "${green}OK${default}."
			else
				echo -e "${red}FAILED${default}."
				rm -rf "${base}/${volname}"
			fi
		fi
	done
}

function doUmount {
	hosts="$(grep sshfs /etc/hosts | awk '{ print $2 }')"
	for host in $hosts; do
		if [ $gnu_sed ]; then
			volname="$(echo $host | sed 's/^./\U&/')"
		else
			volname="${host/.*/}"
		fi
		if [ "`mount -t $filesystem | grep $base/$volname | wc -l`" ]; then
			echo -n "Unmounting volume $volname... "
			$umount ${base}/${volname} && rm -rf ${base}/${volname}
			if [ $? = 0 ]; then
				echo -e "${green}OK${default}."
			else
				echo -e "${red}FAILED${default}."
			fi
		fi
	done
}

gnu_sed=1
filesystem="sshfs.fuse"
umount="fusermount -u"

if [ -f /usr/bin/sw_vers ]; then
	filesystem="osxfusefs"
	umount="umount"
	gnu_sed=0
	if [ ! `hash gsed` ]; then
		gnu_sed=1
	fi
fi

case $1 in
	mount)
		doMount
		;;

	umount|unmount)
		doUmount
		;;

	*)
		echo "Invalid request."
		echo "$0 [mount | umount]"
		exit 1;
		;;
esac
