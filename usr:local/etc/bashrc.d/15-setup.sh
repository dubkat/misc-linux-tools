# 20-setup.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>
ULE_VERSION['setup']=16.10.01
export ULE_RUNTIME=5

if [ -n "$TERM" ]; then
  if [[ $(tput colors) -ge 88 ]]; then
    if [ "$DIRCOLORS_THEME" = "system" ]; then
        eval `dircolors /etc/DIR_COLORS`;
    elif [ -r ${ULE_SETTING['ETC_DIR']}/${DIRCOLORS_THEME}.colors ]; then
      eval `dircolors -b ${ULE_SETTING['ETC_DIR']}/${DIRCOLORS_THEME}.colors`
    fi
  fi
fi

eval `generate_path`
eval `make_user_tmpdir`
#eval `gcc-flags.sh`

if [ -z "$ULE_DONT_TOUCH_MY_PROMPT" ]; then
  export PS1="\[\033[$(unique_user_color)m\]\u\[\033[00;38;5;155;01m\]@\[\033[${MACHINE_COLOR}m\]\h\[\033[00;38;5;195m\] \w\n\[\033[00;38;5;155;01m\]$\[\033[00m\] "
fi

if [ -z "$ULE_SILENT_WELCOME" ]; then
  test -x ${ULE_SETTING['BIN_DIR']}/system-welcome.sh && ${ULE_SETTING['BIN_DIR']}/system-welcome.sh
fi
