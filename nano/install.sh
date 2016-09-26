#!/bin/bash

if test $UID -gt 0; then
    echo "This script will install the accompaning .nanorc files into the system folder." >&2
    echo "This process requires you to be root. Try running this as: sudo $0" >&2
    exit 1
fi

if [ ! -r /etc/nanorc ]; then
    echo "Installing default nanorc to /etc/nanorc"
    install -o root -g root -m 644 nanorc /etc/nanorc
fi

LIST="`command dir $(dirname $0)/*.nanorc`"
echo "$(tput bold)Installing extra syntax hightlighting for nano...$(tput sgr0)"
dest=""
for path in /usr/share/nano /usr/local/share/nano /opt/local/share/nano; do
    if test -d $path -a -x $path; then
        dest="$path"
        break
    fi
done

if [ -z "$dest" ]; then
    echo "Could not find a destination for nano config files. Do you have nano installed ?" >&2
    exit 1
fi

for config in $LIST; do
    echo "Installing ${config##*/} to $dest";
    install -o root -g root -m 644 $config $dest ||:
done

echo "Installation complete."
exit 0
