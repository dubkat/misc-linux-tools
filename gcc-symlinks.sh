#!/bin/sh
# Copyleft (L) 2016 Dan Reidy <dubkat+github@gmail.com>
# create symlinks to gcc/binutils based on local chost (eg. x86_64-suse-linux-gnu-gcc)
# requires: RPM

if [ $UID -ne 0 ]; then
        echo "You must be $(getent -i passwd 0 | awk -F: '{ print $1 }') to run this script."
        exit 1
fi

target=$(rpm -E %{_target_platform}%{?_gnu});
bindir=$(rpm -E %_bindir);
linkdir="/usr/local/bin"

package_list=
for package in $(rpm -qa 'gcc|cpp|binutils|binutils-gold'); do 
        package_list+="$(rpm -ql $package | grep ${bindir} | xargs) "
done

for package in $package_list; do
        if [ ! -x $package ]; then
                echo "skipping non-exec: $package"
                continue
        fi
        name=$(basename $package)
        dest="${linkdir}/${target}-${name}"
        echo "Linking ${package} to ${dest}"
        ln -sf ${package} ${dest}
done

