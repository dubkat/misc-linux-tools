#!/bin/sh
# easy setting of power mode without having to remember cmdline
# (C) 2016 Dan Reidy <dubkat@gmail.com>

colorsetup() {
  if ! hash tput 2>/dev/null; then
    return
  fi
  local colors=`tput colors 2>/dev/null`;
  boldon="$(tput smso)"; boldoff="$(tput rmso)"; colrst="$(tput sgr0)";
  case $colors in
    256 )
      colerr="$(tput setaf 196)"; colwrn="$(tput setaf 190)"; colaok="$(tput setaf 118)";
      ;;

     88 )
      colerr="$(tput setaf 64)"; colwrn="$(tput setaf 76)"; colaok="$(tput setaf 44)";
      ;;

     16 )
      colerr="$(tput setaf 9)"; colwrn="$(tput setaf 11)"; colaok="$(tput setaf 10)";
      ;;

      8 )
      colerr="$(tput setaf 1)"; colwrn="$(tput setaf 3)"; colaok="$(tput setaf 2)";
      ;;

      * )
      # lets err on the side of making sure the screen is readable.
      unset colerr colwrn colaok boldon boldoff colrst;
      ;;
  esac
}


errm() {
  echo "${colerr}*${colrst} $*";
}


warnm() {
  echo "${colwrn}*${colrst} $*";
}

msg() {
  echo "${colaok}*${colrst} $*";
}

colerr=""
colwrn=""
colaok=""
boldon=""
boldoff=""
colrst=""

colorsetup;

if [ $UID -gt 0 ]; then
    if ! id -G -n | grep -Eq '\b(wheel|root|adm)\b'; then
        errm "You are not a super-user."
        exit 1
    fi
fi


case $1 in
  # Full Speed Ahead
  per* )
      msg "Setting power governor to ${boldon}performance${boldoff}."
      sudo modprobe cpufreq_performance 2>/dev/null
      sudo cpupower frequency-set -g performance
      cpupower frequency-info
      ;;

  # Full Speed as needed, Prefer faster
  default|def*|ond* )
      sudo modprobe cpufreq_ondemand 2>/dev/null
      sudo cpupower frequency-set -g ondemand
      cpupower frequency-info
      ;;

  # Full Speed as needed, Prefer slower
    con* )
        sudo modprobe cpufreq_conservative 2>/dev/null
        sudo cpupower frequency-set -g conservative
        cpupower frequency-info
        ;;

  # Slow Traffic, Keep Right.
    pow* )
        sudo modprobe cpufreq_powersave 2>/dev/null
        sudo cpupower frequency-set -g powersave
        cpupower frequency-info
        ;;

    * )
        cpupower frequency-info
        warnm
        warnm "$(basename $0) <default|performance|ondemand|powersave|conservative>"
        warnm "note: default is equivlent to ondemand."
        warnm "modes may be abreviated with the first 3 letters, such as pow for powersave."
        warnm
        false;
        ;;
esac

exit $?
