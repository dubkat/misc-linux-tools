#!/bin/sh
# Copyleft (L) 2016 Dan Reidy <dubkat+github@gmail.com>
# simple script to mount fuse/sshfs/whatever in your home directory.
# it assumes fstab entries like so...
## zenith.box: /home/dubkat/Zenith fuse.sshfs  noauto,users,user=1005,follow_symlinks,transform_symlinks,rw,fsname=fuse 0  0
## dubkat      /home/dubkat/.cache   tmpfs       noauto,nofail,user  0 0

for point in $(grep -E "$USER|user=$UID" /etc/fstab | awk '{ print $2 }'); do
        if ! mountpoint -q "${point}"; then
                mount "${point}" ||:
        fi
done

