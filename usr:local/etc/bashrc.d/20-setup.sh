# 20-setup.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_VERSION['setup']=16.07.01

if [ ! -z "$TERM" ]; then
  if [[ $(tput colors) -ge 88 ]]; then
    if [ -r ${ULE_SETTING['ETC_DIR']}/${DIRCOLORS_THEME}.colors ]; then
      eval `dircolors -b ${ULE_SETTING['ETC_DIR']}/${DIRCOLORS_THEME}.colors`
    fi
  fi
fi


if [ $UID -gt 0 ]; then
        eval `make_user_tmpdir`
        #eval `gcc-flags.sh`
fi

eval `generate_path`


if [ ! -n $DONT_TOUCH_MY_PROMPT ]; then
  export PS1="\[\033[$(unique_user_color)m\]\u\[\033[00;38;5;155;01m\]@\[\033[$(unique_host_color)m\]\h\[\033[00;38;5;195m\] \w\n\[\033[00;38;5;155;01m\]$\[\033[00m\] "
fi

if [ ! -n $SILENT_WELCOME ]; then
  test -x ${ULE_SETTING['BIN_DIR']}/system-welcome.sh && ${ULE_SETTING['BIN_DIR']}/system-welcome.sh
fi
