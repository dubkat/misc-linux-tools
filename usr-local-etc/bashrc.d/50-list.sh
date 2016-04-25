# 50-list.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_LIST_VERSION=16.04.24

export DIRCOLORS_THEME="${DIRCOLORS_THEME:-fruitpunch}"
export LS_OPTIONS="--human-readable --group-directories-first --time-style=long-iso --sort=version --color=auto -b -N"

if [ "x${TERM}x" != "xx" ]; then
        if [[ $(tput colors) -ge 88 ]]; then
        	if [ -r "/usr/local/etc/DIR_COLORS_256.${DIRCOLORS_THEME}" ]; then
	        	eval `dircolors -b /usr/local/etc/DIR_COLORS_256.${DIRCOLORS_THEME}`
	        fi
        fi
fi

#alias ls="command ls"
#alias ls="_ls $LS_OPTIONS"
alias ll="ls -lgG --dereference --classify"
alias l="ls -lA --classify"
