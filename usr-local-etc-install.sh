#!/bin/bash
# Copyleft (7) 2016 Dan Reidy <dubkat@gmail.com>
# simple installer for scripts in /usr/local/etc

DEST="${DEST:-/usr/local/etc}"

[ $UID -gt 0 ] && { echo "You must be root to run this script."; exit 1; }

echo "Installing to ${DEST}"
case `uname -o` in
	"Darwin" )
		BASHRC="${BASHRC:-/etc/bashrc.local}"
		ID="darwin"
		;;
	"Linux" )
		BASHRC="${BASHRC:-/etc/bash.bashrc.local}"
		test -r /etc/os-release && . /etc/os-release
		;;
	* )
		echo "Error: unsupported os. Install Manually or submit a buggreport" >/dev/stderr
		echo "https://github.com/dubkat/misc-linux-tools" >/dev/stderr
		exit 1
		;;
esac

scripts_read="*"
scripts_exec="99-system-welcome.sh"

CUR="$(dirname $(realpath $0))"
if [ -d "${CUR}/usr-local-etc" ]; then
        rsync -av "${CUR}/usr-local-etc/" ${DEST} && {
	        if [ ! -f "${BASHRC}" ]; then
             	   ln -sf ${DEST}/bashrc ${BASHRC}
                else
                   if ! grep -q "${DEST}/bashrc" ${BASHRC}; then
              	     echo >> ${BASHRC}
                     echo "# added by usr-local-etc-installer.sh" >> ${BASHRC}
                     echo "# see ${DEST} for more details" >> ${BASHRC}
                     echo "test -r ${DEST}/bashrc && . ${DEST}/bashrc" >> ${BASHRC}
                     echo >> ${BASHRC}
                  fi
               fi
		chmod 644 ${DEST}/bashrc
		for x in ${DEST}/bashrc.d/${scripts_read}; do
			test -f "${x}" && chmod 644 "${x}"
		done
		for x in ${DEST}/bashrc.d/${scripts_exec}; do
			test -f "${x}" && chmod 755 "${x}"
		done

        }
fi

