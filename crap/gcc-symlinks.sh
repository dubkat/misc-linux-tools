#!/bin/sh
# Copyleft (L) 2016 Dan Reidy <dubkat+github@gmail.com>
# create symlinks to gcc/binutils based on local chost (eg. x86_64-suse-linux-gnu-gcc)
# requires: RPM

cmd="echo ln "
if [ $UID -ne 0 ]; then
        echo "You must be $(getent -i passwd 0 | awk -F: '{ print $1 }') to run this script."
        cmd="echo ln"
fi

#target=$(rpm -E %{_target_platform}%{?_gnu});
target=$(rpm -E %{_target_platform});
bindir=$(rpm -E %_bindir);
linkdir="/usr/bin"

package_list=
for package in gcc gcc-c++ gcc-fortran gcc5 gcc5-c++ gcc5-fortran gcc6 gcc6-c++ gcc6-fortran cpp; do
        package_list+="$(rpm -ql $package 2>/dev/null | grep ${bindir} | xargs) "
done

for package in $package_list; do
        if [ ! -x $package ]; then
                echo "skipping non-exec: $package"
                continue
        fi
        name=$(basename $package)
        dest="${linkdir}/${target}-${name}"
        #echo "Linking ${package} to ${dest}"
        ${cmd} -sf ${package} ${dest}
done

echo "export PATH=${linkdir}:$PATH"

# update-alternatives --install 
