# 10-environ.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>

ULE_ENV_VERSION=16.05.08

#test -f /etc/portage/make.conf && . /etc/portage/make.conf

: ${TMPDIR:=
: ${TZ:=UTC}
: ${COLORIZE:=yes}
: ${LANG:=en_US.UTF-8}
: ${MAN_POSIXLY_CORRECT:=1}
: ${CFLAGS:= -march=native -O2 -fPIC -fPIE -pie -fstack-protector-strong -pipe }
: ${CPPFLAGS:= -D_FORTIFY_SOURCE=2 }
: CXXFLAGS="${CFLAGS}"
: FFLAGS="${CFLAGS}"
: ${LDFLAGS:= -Wl,-O2 -Wl,--sort-common -s -Wl,--as-needed -Wl,-pie}
: ${DEFAULT_BASH_OPTS:=extglob autocd cdspell checkjobs checkwinsize dirspell histappend huponexit}

if [ "$is" = "bash" ]; then
  for x in $DEFAULT_BASH_OPTS; do
    shopt -s $x
  done
fi

export TMPDIR="${TMPDIR:-/run/user/${UID}/tmp}"
export CHOST="$(rpm -E %_target_platform 2>/dev/null)"
export COLORIZE;
export TZ;
export MAN_POSIXLY_CORRECT;
export CFLAGS;
export CXXFLAGS;
export LDFLAGS;

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
