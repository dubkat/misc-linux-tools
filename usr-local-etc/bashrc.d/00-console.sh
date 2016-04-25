# Extra bash custimizations. The real magic happens in /usr/local/etc/bashrc.d
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_CON_VERSION=16.04.24
case $TERM in
	linux )
		export TERM="linux-16color"
		setterm -blank 0 2>/dev/null
	;;
	xterm )
		export TERM="xterm-256color"
	;;
esac

