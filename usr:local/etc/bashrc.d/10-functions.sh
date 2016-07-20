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

# generate a random whole number between 0 and X (255 by default)
rand() {
  local ceil=${1:-255}
  case $ceil in
    *[0-9]* )
    perl -le '{ print int(rand(shift)); }' $ceil;
    ;;
  esac
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

# A best-effort to create color based on the uniqueness of
# your mac address, or hostname. Thus each machine you have
# should have very unique colors.
unique_host_color() {
  if ! hash colout 2>/dev/null; then
    echo -n "1;38;5;$(rand)"
  fi
  local string;
  local device;
  local escape;
  # based on mac address
  # we look for the direct path ourselves as /sbin is likely not in
  # our users path.
  if [ -x "/sbin/ip" ]; then
    device=$(command /sbin/ip route show 0.0.0.0/0 | awk '{ print $5 }');
    string=$(command /sbin/ip addr show $device | grep 'link/ether' | awk '{ print $2 }');
  elif [ -x "/sbin/ifconfig" -a -x "/sbin/route" ]; then
    device="$(command /sbin/route|grep default|awk '{ print $NF }')"
    string="$(command /sbin/ifconfig $device|grep HWaddr|awk '{ print $NF }'|tr '[A-Z]' '[a-z]' )"
  elif hash hostnamectl 2>/dev/null; then
    string="$(command hostnamectl --static)"
  else
    string="$(command hostname -f)"
  fi
  if [ -z "$string" ]; then
    escape="1;38;5;$(rand)"
  else
    escape="$(echo $string | colout '^.*$' Hash | cat -v | grep -Po '[01];38;5;\d+')"
  fi
  echo -n "$escape"
}

unique_user_color() {
  local escape;
  if ! hash colout 2>/dev/null; then
    escape="1;38;5;`rand`";
  else
    escape="$(echo $USER | colout '^.*$' Hash | cat -v | grep -Po '[01];38;5;\d+')"
  fi
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

## crypto_backend
# determine what crypto engine a binary is using.
# usage: crypt_backend irssi
# example return:
# irssi-git/0.8.19+100+g0e5a32f:  /usr/bin/irssi
# libssl38/2.3.4: /usr/lib64/libssl.so.38
# libcrypto37/2.3.4:      /usr/lib64/libcrypto.so.37
crypto_backend ()
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
  rpm -qf --queryformat "%{VENDOR}\t%{N}/%{V}:\t$shared\n" $shared;
  for backend in $(ldd $shared | egrep '(gcrypt|nettle|weed|ssl|crypto)' | awk '{ print $3 }'); do
    rpm -qf --queryformat "%{VENDOR}\t%{N}/%{V}:\t$backend\n" $backend;
  done
}

session_id() {
  if [ -n "$ULE_SESSION_ID" ]; then
    echo "export ULE_SESSION_ID=$ULE_SESSION_ID";
    return;
  fi

  if hash uuid 2>/dev/null; then
    uuid=$(uuid -v1);
  elif hash uuidgen 2>/dev/null; then
    uuid=$(uuidgen -t);
  else
    uuid="$(random.sh 192 2>/dev/null | tr '/' '+')"
  fi
  export ULE_SESSION_ID=$uuid
  echo "export ULE_SESSION_ID=$uuid"
}

# create user designated tmpdir location, if it doesn't exist.
function make_user_tmpdir() {


  if [ -n "$TMPDIR" ]; then
    if [ "$TMPDIR" = "/tmp" ]; then
      unset TMPDIR
      make_user_tmpdir
    fi
    return
  fi

  if [ -d "/tmp" -a -x "/tmp" ]; then
    TMPDIR="/tmp/${USER}"
  elif [ -d "/var/tmp" -a -x "/var/tmp" ]; then
    TMPDIR="/var/tmp/${USER}"
  elif [ -d "/usr/local/tmp" -a -x "/usr/local/tmp" ]; then
    TMPDIR="/usr/local/tmp/${USER}"
  else
    TMPDIR="${HOME}/.cache/tmp"
  fi

  if [ ! -d "${TMPDIR}" ]; then
    mkdir -p "${TMPDIR}"
    chmod 700 "${TMPDIR}"
  fi
  export TMPDIR=${TMPDIR}
  echo export TMPDIR=${TMPDIR}
}

function vman {
  /usr/bin/man $* | col -bp | iconv -c | view -c 'set ft=man nomod nolist' -
}

function xephyr {
  local winmode=win
  local host=broadcast
  if ! hash Xephyr 2>/dev/null; then
    echo "The program Xephyr is not installed. You can probably find it among " >&2
    echo "your Xorg packages." >&2
    return 1
  fi
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

  xephyr="Xephyr -br -ac -noreset -fp tcp/localhost:7100 +iglx "
  if [ "$winmode" = "win" ]; then
    xephyr+="-screen 1280x720 "
  elif [ "$windmode" = "fs" ]; then
    xephyr+="-fullscreen "
  fi
  if [ "$host" = "broadcast" ]; then
    xephyr+="-broadcast "
  else
    xephyr+="-query $host "
  fi
  xephyr+=":1 "
  echo $xephyr >&2
  $xephyr >/dev/null 2>&1 &
  return $?
}

unset ULE_RUNTIME
