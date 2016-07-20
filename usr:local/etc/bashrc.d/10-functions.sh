# 99-functions.sh
# Copyright (C) 2015-2016 Dan Reidy <dubkat@gmail.com>
ULE_VERSION['functions']=16.07.20
export ULE_RUNTIME=4

function _ls ()
{
    local IFS=' ';
    command ls $LS_OPTIONS ${1+"$@"}
}

ule_version() {
cat<<EOF
Copyright 2015-$(date +%Y) Dan Reidy <dubkat@gmail.com>
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

usr:local module versions:
EOF
        for x in $ULE_MODULES; do
                printf "%12s: %s\n" $x ${ULE_VERSION[$x]}
        done

}

ule_uname() {
        if [ ! -z "$@" ]; then
                command uname $@
                return $?
        fi
        local opts="nodename machine processor hardware-platform operating-system kernel-name kernel-release kernel-version";
        for x in $opts; do
                printf "* %20s: %s\n" "${x}" "$(uname --${x})";
        done
}


generate_path() {
  local user="/opt/local/libexec/gnubin /opt/local/bin /usr/local/bin /usr/games /opt/bin /usr/bin /bin";
  local admin="/usr/local/sbin /opt/local/sbin /opt/sbin /usr/sbin /sbin";
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
  echo export PATH=$path
}

unique_host_color() {
	if ! hash colout 2>/dev/null; then
		return
	fi
	local hostname="$(hostname -f)"
	local escape="$(echo $hostname | colout '^.*$' Hash | cat -v | grep -Po '1;38;5;\d+')"
	echo -n "$escape"
}

unique_user_color() {
	if ! hash colout 2>/dev/null; then
		return
	fi
	local escape="$(echo $USER | colout '^.*$' Hash | cat -v | grep -Po '1;38;5;\d+')"
	echo -n "$escape"
}

genpasswd() {
  local arg=$1
  : ${arg:-256}
  if hash random.sh 2>/dev/null; then
    random.sh $arg
  else
    echo "please download random.sh from https://github.com/dubkat/misc-linux-tools" >&2
  fi
}

perlmodtest() {
  local module="${1:?a Module::Name is required as an arguement.}"
  perl -C6 -M${module} -le '{ printf "Module %s Loaded OK.\n", shift;  }' $module
  #perl -T -Mstrict -M${module} -le '{ printf "* Module %s was found in \@INC\n", shift }' ${module}
}

crypt_backend ()
{
  if ! hash rpm 2>/dev/null; then
    echo "This function requires an rpm based system."
    return 1
  fi
  local shared="${1:?first argument must be a shared execuatble}"
  if [ ! -f "$shared" ]; then
    if ! hash $shared 2>/dev/null; then
      echo "error: $shared is not found." >&2
      return 1
    else
      shared="$(hash -t $shared)"
    fi
  fi
  rpm -qf --queryformat "%{N}/%{V}:\t$shared\n" $shared;
  for backend in $(ldd $shared | egrep '(gcrypt|nettle|weed|libssl|libcrypto)' | awk '{ print $3 }'); do
    rpm -qf --queryformat "%{N}/%{V}:\t$backend\n" $backend;
  done
}

# create user designated tmpdir location, if it doesn't exist.
function make_user_tmpdir() {
  [ $UID -eq 0 ] && return 0;
  local uuid;
  if hash uuid 2>/dev/null; then
    uuid=$(uuid -v1);
  elif hash uuidgen 2>/dev/null; then
	   uuid=$(uuidgen -t);
  else
    uuid="$(random.sh 192 2>/dev/null | tr '/' '+')"
  fi
  mkdir -p "/tmp/${uuid}"
  chmod 700 "/tmp/${uuid}"
  echo export TMPDIR="/tmp/${uuid}"
}

function vman {
  /usr/bin/man $* | col -bp | iconv -c | view -c 'set ft=man nomod nolist' -
}

function xephyr {
	local winmode=win
	local host=broadcast
	if [ ${#@} -gt 2 ]; then
		echo "usage: xephyr <window|fullscreen> [host]" >&2
		exit 1
	fi
	for arg in $@; do
		case $arg in
			win|window) winmode=win; ;;
			fs|fullscreen|full) winmode=fs; ;;
			broadcast|broad|bc|255.255.255.255) host=broadcast; ;;
			* ) host="$arg"; ;;
		esac
	done

	xephyr="Xephyr -query acid.unix-world.zone -br -ac -noreset -fp tcp/localhost:7100 +iglx "
	if [ "$winmode" = "win" ]; then
		xephyr+="-screen 1280x720 :1 "
	elif [ "$windmode" = "fs" ]; then
		xephyr+="-fullscreen "
	fi
	if [ "$host" = "broadcast" ]; then
		xephyr+="-broadcast "
	else
		xephyr+="-query $host"
	fi
	$xephyr >/dev/null 2>&1 &
	return $?
}
