#!/bin/sh
# simple script installer
# (C) 2016 Dan Reidy <dubkat@gmail.com>

prefix="${prefix:-/usr/local}"
env_prefix="${prefix}/etc"
bin_prefix="${prefix}/bin"
owner=root
group=root

if [ ! -z "$1" ]; then
        if [ "$1" = "local-install" ]; then
                bin_dir="~/bin"
                env_dir="~/.local/share/ule-scripts"
                owner="$(id -u -n)"
                group="$(id -g -n)"
        elif [ "$1" = "custom-prefix" ]; then
                prefix="${2?you must include a prefix directory}"
                bin_dir="${prefix}/bin"
                env_dir="${prefix}/etc"
        fi
else
        if [ $UID -gt 0 ]; then
                echo "You must be root to install globally."
                echo "If you want a local user copy, run this script again like so..."
                echo "$0 local-install"
                exit 1
        fi
fi

i=0
MISSING="";
BINS="figlet toilet finger whois geoiplookup curl colout"
echo -n "Testing for required binaries... "
for x in $BINS; do
        echo -n "$x "
        if ! hash $x 2>/dev/null; then
                i=$[i + 1]
                MISSING+="$x "
        fi
done
echo
if [ $i -gt 0 ]; then
        echo "Please install the $i missing packages: $MISSING"
        exit $i
fi

echo "Installing to $(realpath ${prefix})"


mkdir -p -m 755 ${bin_prefix} 2>/dev/null; chmod 755 ${bin_prefix} 2>/dev/null
mkdir -p -m 755 ${env_prefix}/bashrc.d 2>/dev/null; chmod 755 ${env_prefix}/bashrc.d 2>/dev/null

install -o root -g root -m 644 etc/bashrc etc/fruitpunch-256.colors etc/zenburn-256.colors ${env_prefix}

install -o root -g root -m 644 etc/bashrc.d/* ${env_prefix}/bashrc.d
if [ ! -f ${env_prefix}/bashrc.d/01-local.sh ]; then
        touch ${env_prefix}/bashrc.d/01-local.sh
        echo "# Place your custom options here." > ${env_prefix}/bashrc.d/01-local.sh
fi
if [ ! -f ${env_prefix}/bashrc.d/99-local.sh ]; then
        touch ${env_prefix}/bashrc.d/99-local.sh
        echo "# Place your custom options here." > ${env_prefix}/bashrc.d/99-local.sh
fi


for x in bin/*; do
        install -o root -g root -m 755 ${x} ${prefix}/${x}
done

