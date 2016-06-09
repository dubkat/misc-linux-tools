# 20-setup.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_VERSION['setup']=16.06.04

if [ ! -z "$TERM" ]; then
  if [[ $(tput colors) -ge 88 ]]; then
    if [ -r ${ULE_SETTING['ETC_DIR']}/${DIRCOLORS_THEME}.colors ]; then
      eval `dircolors -b ${ULE_SETTING['ETC_DIR']}/${DIRCOLORS_THEME}.colors`
    fi
  fi
fi

eval `make_user_tmpdir`
eval `generate_path`
eval `gcc-flags.sh`

export PS1="\[\033[$(unique_user_color)m\]\u\[\033[00;38;5;155;01m\]@\[\033[$(unique_host_color)m\]\h\[\033[00;38;5;195m\] \w\n\[\033[00;38;5;155;01m\]$\[\033[00m\] "

test -x ${ULE_SETTING['BIN_DIR']}/system-welcome.sh && ${ULE_SETTING['BIN_DIR']}/system-welcome.sh
