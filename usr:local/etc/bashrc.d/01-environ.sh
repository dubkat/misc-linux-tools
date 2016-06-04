# 10-environ.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>

ULE_VERSION['environ']=16.06.04

: ${TZ:=UTC}
: ${COLORIZE:=yes}
: ${LANG:=en_US.UTF-8}
: ${LANGUAGE:=en_US}
: ${MAN_POSIXLY_CORRECT:=1}
: ${POSIXLY_CORRECT:=0}
: ${CFLAGS:= -march=native -O2 -fPIE -fstack-protector-strong -pipe }
: ${CPPFLAGS:= -D_FORTIFY_SOURCE=2 }
: ${LDFLAGS:= -Wl,-O2 -Wl,--sort-common -s -Wl,--as-needed -Wl,-pie}
: ${DEFAULT_BASH_OPTS:=extglob autocd cdspell checkjobs checkwinsize dirspell histappend huponexit}
: ${DIRCOLORS_THEME:-fruitpunch}
: ${LS_OPTIONS:- --human-readable --group-directories-first --time-style=long-iso --sort=version --color=auto -b -N }

if [ "$is" = "bash" ]; then
  for x in $DEFAULT_BASH_OPTS; do
    shopt -s $x
  done
fi

export CHOST="${MACHTYPE:=`uname -p`-unknown-linux}"
export COLORIZE;
export TZ;
export LANG;
export LANGUAGE;
export LC_ALL=${LANG}
export MAN_POSIXLY_CORRECT;
export POSIXLY_CORRECT;
export CFLAGS;
export CXXFLAGS=\${CFLAGS}
export FFLAGS=\${CFLAGS}
export LDFLAGS;
export DIRCOLORS_THEME;
export LS_OPTIONS;

# change grep's default color
export GREP_COLORS="ms=00;38;5;075:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36"
export DI_ARGS="-h -ssm -f SMbuf1T"
export IDN_DISABLE=1
export PERLDOC="-MPod::Perldoc::ToTerm -o term -w indent:5 -w loose:true -w sentence:false"
export PERL_UNICODE="6"
export PERLDB_OPTS="NonStop=1 AutoTrace=1 frame=2"

# export a simple, basic, standard path.
# later in functions and cleanup we expand it.
export PATH="/usr/local/bin:/usr/bin:/bin"

unalias ls 2>/dev/null ||:

