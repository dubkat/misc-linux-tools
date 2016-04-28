# 10-environ.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat+github@gmail.com>

ULE_ENV_VERSION=16.04.24

#test -f /etc/portage/make.conf && . /etc/portage/make.conf

: ${TZ:=UTC}
: ${COLORIZE:=yes}
: ${LANG:=en_US.UTF-8}
: ${MAN_POSIXLY_CORRECT:=1}
: ${CFLAGS:= -march=native -O2 -D_FORTIFY_SOURCE -fPIE -fstack-protector-strong -pipe }
: ${CXXFLAGS:= \${CFLAGS} }
: ${FFLAGS:= \${CFLAGS} }
: ${LDFLAGS:= -Wl,-O2 -Wl,--sort-common -s -Wl,--as-needed -Wl,-pie}
: ${DEFAULT_BASH_OPTS:=extglob autocd cdspell checkjobs checkwinsize dirspell histappend huponexit}

if [ "$is" = "bash" ]; then
        for x in $DEFAULT_BASH_OPTS; do
                shopt -s $x
        done
fi

export TMPDIR="/run/user/${UID}/tmp"
export CHOST="$(rpm -E %_target_platform 2>/dev/null)"
export COLORIZE;
export TZ;
export MAN_POSIXLY_CORRECT;
export CFLAGS;
export CXXFLAGS;
export LDFLAGS;

# change grep's default color
export GREP_COLORS="ms=00;38;5;075:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36"
export DI_ARGS="-h -s m -f SMbuf1T"
export IDN_DISABLE=1
export PERLDOC="-MPod::Perldoc::ToTerm -o term -w indent:5 -w loose:true -w sentence:false"
export PERL_UNICODE="6"
export PERLDB_OPTS="NonStop=1 AutoTrace=1 frame=2"


#export DISTCC_HOSTS="localhost azimuth,cpp,lzo"

test_path() {
	local user="/usr/local/bin /usr/games /opt/bin /usr/bin /bin";
	local admin="/usr/local/sbin /opt/sbin /usr/sbin /sbin";
	#local portage="$(/usr/bin/gcc-config -B) /lib64/rc/bin";
	local path;
	if ! groups | /bin/grep -qE '\b(root|wheel|adm|operator)\b'; then
		unset admin
	fi
	if ! groups | /bin/grep -qE '\b(portage)\b'; then
		unset portage
	fi
	for x in ${HOME}/bin $portage $admin $user; do
		[[ -d $x ]] && [[ -x $x ]] && {
			[[ ${#path} > 0 ]] && path+=":"
			path+=${x}
		};
	done
	echo "export PATH=$path"
}

eval `test_path`

