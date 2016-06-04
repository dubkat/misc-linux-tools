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

test -x ${ULE_SETTING['BIN_DIR']}/system-welcome.sh && ${ULE_SETTING['BIN_DIR']}/system-welcome.sh
