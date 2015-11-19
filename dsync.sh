#!/bin/bash
# dsync.sh - syncronize local_dir <--> ssh_server <--> remote_laptop (etc)
# (C) 2014 Dan Reidy <dubkat@gmail.com>
# http://github.com/dubkat/misc-linux-tools
# this script assumes 1 important security fact.
# you must trust the middleman server.

dryrun=0
for arg in $@;do
	case ${arg} in
		simple )
			upextra="${upextra}"
			downextra="${downextra}"
			;;
		push )
			upextra="${upextra} --delete-before --prune-empty-dirs"
			pushup=1
			;;
		pull )
			downextra="${downextra} --delete-before --prune-empty-dirs"
			pulldown=1
			;;
		test|dry-run )
			if [ $dryrun = 0 ]; then
				upextra="${upextra} --dry-run"
				downextra="${downextra} --dry-run"
			fi
			dryrun=1
			;;
		default )
			upextra=
			downextra=
			if [ $dryrun = 1 ]; then
				upextra="--dry-run"
				downextra="--dry-run"
			fi
			break
			;;
		* )
			echo "Invalid Option: $arg" >&2
			exit 1;
			;;
	esac
done


now=$(date +%F_%H:%M:%S)
test -r ~/.dsyncrc && . ~/.dsyncrc

syncfile="sync-${HOSTNAME}"
upextra="${upextra} ${dsync_upextra}"
downextra="${downextra} ${dsync_downextra}"
dsync_dir="${dsync_dir:-${HOME}/.dsync}"

echo "extra-args:   up: $upextra"
echo "extra-args: down: $downextra"
echo " dsync dir: $dsync_dir"

dsync_middleman="${dsync_middleman:?option dsync_middleman not set. this is obviously required. set dsync_middleman='$REMOTE_HOST' in ~/.dsyncrc}"

dsync_sync="${dsync_sync:?option dsync_sync not set. this is required. set dsync_sync='DIRS_TO_SYNC' -- relative to your homedir}"


if [ -z $RSYNC_RSH ]; then
	if [ -z $dsync_protocol ]; then
		echo "Please set and export RSYNC_RSH=ssh"
		echo "or set dsync_protocol=ssh in ~/.dsyncrc"
		exit 1;
	fi
	RSYNC_RSH="$dsync_protocol"
fi
export RSYNC_RSH;

defaultopts=" -azL --perms --xattrs --hard-links --times --update --backup --sparse --cvs-exclude --delay-updates"

if [ $dryrun = 1 ]; then
	echo "Notice: Sync is running in testing mode." >&2
	echo "Notice: No changes being made." >&2
fi


test -d "${dsync_dir}" || mkdir -p "${dsync_dir}";
chmod 700 ${dsync_dir}

ssh $dsync_middleman "test -d backups || { mkdir -p backups ; chmod 700 backups; }" >/dev/null 2>&1

for dir in $dsync_sync; do
	dirname="${dir}"
	dirname="${dirname##\.}"
	dirname="${dirname//\//::}"
	if [ ! $pulldown ];
	then
		if [ -d "${HOME}/${dir}" ]; then
			sf="${syncfile}-${dirname}-${now}.sha1"
			sync
			echo "Creating checksum file $sf"
			if [ $dryrun = 0 ]; then
				find -O3 ${HOME}/${dir} -type f -a ! -iname "sync-*-${dirname}*" -exec sha1sum '{}' >> ${dsync_dir}/${sf} +
				test -f ${HOME}/${dir}/${syncfile}-${dirname}-current.sha1 && rm ${HOME}/${dir}/${syncfile}-${dirname}-current.sha1
				ln ${dsync_dir}/${sf} ${HOME}/${dir}/${syncfile}-${dirname}-current.sha1 || \
				ln -s ${dsync_dir}/${sf} ${HOME}/${dir}/${syncfile}-${dirname}-current.sha1

			fi
			echo "Uploading changes in ${HOME}/${dir}"
			rsync ${defaultopts} ${upextra} "${HOME}/${dir}/" "${dsync_middleman}:backups/${dirname}" >/dev/null 2>&1 || \
			{
				msg="Sync Error: rsync finished uploading $HOME/$dir with errorcode: $?"
				if hash colout >/dev/null; then
					echo $msg | colout "^(Sync Error):.*($HOME/$dir) .*: (\d+)$" red,white,cyan
				else
					echo $msg
				fi
				echo "Command was: rsync ${defaultopts} ${upextra} \"${HOME}/${dir}/\" \"${dsync_middleman}:backups/${dirname}\""
				exit 1
			}
			test -f "${HOME}/${dir}/${sf}" && rm "${HOME}/${dir}/${sf}"
		fi
	fi
	if [ ! $pushup ];
	then
		echo "Downloading changes to ${HOME}/${dir}"
		sync
		rsync ${defaultopts} ${downextra} "${dsync_middleman}:backups/${dirname}/" "${HOME}/${dir}" >/dev/null 2>&1 || \
		{
			msg="Sync Error: rsync finished downloading $HOME/$dir with errorcode: $?"
			if hash colout >/dev/null; then
				echo $msg | colout "^(Sync Error):.*($HOME/$dir) .*: (\d+)$" red,white,cyan
			else
				echo $msg
			fi
			exit 1
		}
		sync
	fi
done

if [ $dryrun = 0 ]; then
	echo "Syncing Checksums."
	rsync ${defaultopts} ${upextra} "${dsync_dir}/" "${REMOTE}:backups/checksums" >/dev/null 2>&1
	rsync ${defaultopts} ${downextra} "${REMOTE}:backups/checksums/" $dsync_dir >/dev/null 2>&1 
fi

if [ ! $pushup ]; then
	echo "Checking for file corruptions/errors."
	if hash colout 2>/dev/null; then
		find ${HOME} -O3 -iname "sync-*-current.sha1" -a -not -iname "sync-${HOSTNAME}-*.sha1" -exec sha1sum --quiet -c '{}' 2>/dev/null \; -a -delete | colout '^(?:(.+): (OK)|(.+): (FAILED))' black,green,white,red
	else
		find ${HOME} -O3 -iname "sync-*-current.sha1" -a -not -iname "sync-${HOSTNAME}-*.sha1" -exec sha1sum --quiet -c '{}' 2>/dev/null \; -a -delete
	fi
fi

echo "Sync done."
exit 0


