#!/bin/bash
# Copyleft (7) 2016 Dan Reidy <dubkat@gmail.com>
# simple installer for scripts in /usr/local/etc

DEST="${DEST:-/usr/local/etc}"

[ $UID -gt 0 ] && { echo "You must be root to run this script."; exit 1; }

echo "Installing to ${DEST}"
test -r /etc/os-release && . /etc/os-release

CUR="$(dirname $(realpath $0))"
if [ -d "${CUR}/usr-local-etc" ]; then
        rsync -av "${CUR}/usr-local-etc/" ${DEST} && {
                case $ID in
                        opensuse )
                                if [ ! -f /etc/bash.bashrc.local ]; then
                                        ln -sf ${DEST}/bashrc /etc/bash.bashrc.local
                                else
                                        if ! grep -q "${DEST}/bashrc" /etc/bash.bashrc.local; then
                                                echo >> /etc/bash.bashrc.local
                                                echo "# added by usr-local-etc-installer.sh" >> /etc/bash.bashrc.local
                                                echo "# see ${DEST} for more details" >> /etc/bash.bashrc.local
                                                echo "test -r ${DEST}/bashrc && . ${DEST}/bashrc" >> /etc/bash.bashrc.local
                                                echo >> /etc/bash.bashrc.local
                                        fi
                                fi
				chmod 644 ${DEST}/bashrc
                                ;;
                        * )
                                ;;

                esac

        }

fi

