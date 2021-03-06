# 10-environ.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>

ULE_VERSION['environ']=16.10.02
export ULE_RUNTIME=5

bits=32
if [ "`uname -m`" = "x86_64" ]; then
  bits=64
fi

: ${TZ:=UTC}
: ${COLORIZE:=yes}
: ${LANG:=en_US.UTF-8}
: ${LANGUAGE:=en_US.UTF-8}
: ${MAN_POSIXLY_CORRECT:=1}
: ${POSIXLY_CORRECT:=0}
if [ -z "$ULE_DONT_TOUCH_MY_CFLAGS" ] && [ "`uname -s`" != "Darwin" ]; then
: ${CFLAGS:="-march=native -O2 -g -m$bits -fmessage-length=0 -D_FORTIFY_SOURCE=2 -fstack-protector-strong -funwind-tables -fasynchronous-unwind-tables -fPIC -pipe" }
: ${CXXFLAGS:=$CFLAGS}
: ${FFLAGS:=$CFLAGS}
: ${CPPFLAGS:="-D_FORTIFY_SOURCE=2" }
: ${LDFLAGS:="-Wl,-O2 -Wl,--sort-common -s -Wl,--as-needed" }
fi
: ${DIRCOLORS_THEME:="fruitpunch" }
: ${LS_OPTIONS:="--human-readable --group-directories-first --time-style=long-iso --sort=version --color=auto -b -N" }
: ${XEPHYR_WIN_SIZE:="1280x800"}
: ${GREP_COLORS:="ms=${MACHINE_COLOR:-$DISTRO_COLOR}:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36"}

if [ -z "$CHOST" ]; then
  if hash rpm 2>/dev/null; then
    CHOST="$(rpm -E %_target_platform)"
  elif hash gcc 2>/dev/null; then
    CHOST="$(gcc -dumpmachine)"
  fi
fi

export CHOST;
export COLORIZE;
export TZ;
export LANG;
export LANGUAGE;
export LC_ALL=${LANG}
export MAN_POSIXLY_CORRECT;
export POSIXLY_CORRECT;
export LDFLAGS;
export DIRCOLORS_THEME;
export LS_OPTIONS;
export XEPHYR_WIN_SIZE;

# change grep's default color
export GREP_COLORS
export DI_ARGS="-h -ssm -f SMbuf1T"
export IDN_DISABLE=0
export PERLDOC="-MPod::Perldoc::ToTerm -o term -w indent:5 -w loose:true -w sentence:false"
export PERL_UNICODE="6"
export PERLDB_OPTS="NonStop=1 AutoTrace=1 frame=2"

# export a simple, basic, standard path.
# later in functions and cleanup we expand it.
export PATH="${ULE_SETTING['BIN_DIR']}:/usr/bin:/bin"


unset bits
unalias ls 2>/dev/null ||:
