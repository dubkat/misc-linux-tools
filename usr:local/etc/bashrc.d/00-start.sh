# Extra bash custimizations. The real magic happens in /usr/local/etc/bashrc.d
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_VERSION['start']=16.06.8

unset LS_COLORS
unset LS_OPTIONS

test -r ~/.bashrc && source ~/.bashrc

case $TERM in
	"linux" )
	if TERM="linux-16color" tput longname >/dev/null 2>&1; then
		export TERM="linux-16color"
		setterm -blank 0 2>/dev/null
                tput init
	fi
	;;

	"xterm" )
	if TERM="xterm-256color" tput longname >/dev/null 2>&1; then
		export TERM="xterm-256color"
                tput init
	fi
	;;

        "rxvt-unicode-256color" )
        if [ "`uname -o`" = "Darwin" ]; then
                if ! tput longname >/dev/null 1>&1; then
                        export TERM="rxvt-256color"
                        tput init
                fi
        fi
        ;;
esac



