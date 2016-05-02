# Extra bash custimizations. The real magic happens in /usr/local/etc/bashrc.d
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_CON_VERSION=16.05.02
case $TERM in
	"linux" )
	if TERM="linux-16color" tput longname >/dev/null 2>&1; then
		export TERM="linux-16color"
		setterm -blank 0 2>/dev/null
	fi
	;;

	"xterm" )
	if TERM="xterm-256color" tput longname >/dev/null 2>&1; then
		export TERM="xterm-256color"
	fi
	;;
esac

tput init
