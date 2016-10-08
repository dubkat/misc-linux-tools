#!/usr/bin/env bash
# free-disk-cache - Free up memory by dropping disk cache
# Copyleft (L) 2016 Dan Reidy <dubkat+github@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Idea taken from pissedoffadmins.com
# http://pissedoffadmins.com/os/script-to-free-up-cached-memory.html


function drop_cache {
  sync
  if test $UID -gt 0; then
    sudo sysctl vm.drop_caches=3 >/dev/null
  else
    sysctl vm.drop_caches=3 >/dev/null
  fi
}

function permem {
  local in=$1;
  echo "($in * 100) / $memory_total " | bc

}

function kb2mb {
  k=$1;
  echo "$k / 1024" | bc;
}

: ${red:=}
: ${yel:=}
: ${hil:=}
: ${gre:=}
: ${blu:=}
: ${wht:=}
: ${gry:=}
: ${pur:=}
: ${bld:=}
: ${rst:=}

if hash tput 2>/dev/null; then
  colors=$(tput colors);
  bld=$(tput bold);
  rst=$(tput sgr0);
  if test $colors -eq 256; then
    red=$(tput setaf 196);    yel=$(tput setaf 226);    hil=$(tput setaf 154);
    gre=$(tput setaf  82);    blu=$(tput setaf  81);    wht=$(tput setaf 255);
    gry=$(tput setaf 245);    pur=$(tput setaf 104);
  elif test $colors -ge 88; then
    red=$(tput setaf 64);     yel=$(tput setaf 76);     hil=$(tput setaf 44);
    gre=$(tput setaf 28);     blu=$(tput setaf 43);     wht=$(tput setaf 63);
    gry=$(tput setaf 83);     pur=$(tput setaf 55);
  else
    red=$(tput setaf 9);      yel=$(tput setaf 3);      hil=$(tput setaf 11);
    gre=$(tput setaf 10);     blu=$(tput setaf 12);     wht=$(tput setaf 15);
    gry=$(tput setaf 8);      pur=$(tput setaf 13);
  fi
  unset colors;

fi


if ! groups | grep -Eq 'wheel|root'; then
  echo "${red}* ${gry}This script can only be run by the ${wht}root${gry} user or ${wht}wheel${gry} member.${rst}" > /dev/stderr
  exit 1
fi

if ! hash bc 2>/dev/null; then
  echo "${red}* ${wht}bc${gry} not found.${rst}" > /dev/stderr
  exit 1
fi

if [ $UID -gt 0 ]; then
        if ! hash sudo 2>/dev/null; then
          echo "${red}* ${wht}sudo${gry} not found.${rst}" > /dev/stderr
          exit 1
        fi
fi

status_only=1
if [ ! -z "$1" ]; then
  case "$1" in
     "-f"|"--flush" ) status_only=0; ;;
     * )
        echo -e "${red}*${rst} usage: ${bld}$(basename $0)${rst}";
        echo -e "${red}*${rst} usage: ${bld}$(basename $0) -f|--flush${rst}";
        exit 1;
        ;;
  esac
fi

[ $status_only -eq 0 ] && printf "${bld}Please Wait...${rst}"
memory_total=$(awk '/MemTotal/ { print $2 }' /proc/meminfo);
memory_active=$(awk '/^Active:/ { print $2 }' /proc/meminfo);
memory_active_anon=$(awk '/^Active.anon.:/ { print $2 }' /proc/meminfo);
memory_active=$[memory_active + memory_active_anon];
memory_cached_pre=$(awk '/^Cached/ { print $2 }' /proc/meminfo);
memory_free_pre=$(awk '/MemFree/ { print $2 }' /proc/meminfo);
memory_buffers=$(awk '/Buffers/ { print $2 }' /proc/meminfo);
if [ $status_only -eq 0 ]; then
  drop_cache
  memory_free_post=$(awk '/MemFree/ { print $2 }' /proc/meminfo);
  memory_total_freed=$(echo ${memory_free_post} - ${memory_free_pre} | bc);
fi
printf "\n\n"

# print top border
printf " \u2554"; for x in `seq 1 44`; do printf "\u2550"; done; printf "\u2555\n";

printf " \u2551 ${gry}%-20s${rst} ${bld}${red}%'11.02f${rst} ${wht}%-3s${rst}       \u2502\n" "Total Memory" $(kb2mb $memory_total) "Mb";
printf " \u2551 ${gry}%-20s${rst} ${red}%'11.02f${rst} ${wht}%-3s${rst} %3d%%  \u2502\n" "Active" $(kb2mb $memory_active) "Mb" $(permem $memory_active);
printf " \u2551 ${gry}%-20s${rst} ${yel}%'11.02f${rst} ${wht}%-3s${rst} %3d%%  \u2502\n" "Buffers" $(kb2mb $memory_buffers) "Mb" $(permem $memory_buffers);
printf " \u2551 ${gry}%-20s${rst} ${pur}%'11.02f${rst} ${wht}%-3s${rst} %3d%%  \u2502\n" "Cached Memory" $(kb2mb $memory_cached_pre) "Mb" $(permem $memory_cached_pre);
printf " \u2551 ${gry}%-20s${rst} ${gre}%'11.02f${rst} ${wht}%-3s${rst} %3d%%  \u2502\n" "Start Free Memory" $(kb2mb $memory_free_pre) "Mb" $(permem $memory_free_pre);


if [ $status_only -eq 0 ]; then
  # print seperator bar
  printf " \u255F"; for x in `seq 1 44`; do printf "\u2500"; done; printf "\u2524\n"

  printf " \u2551 ${wht}%-20s${rst} ${bld}${blu}%'11.02f${rst} ${wht}%-3s${rst} %3d%%  \u2502\n" "Memory Freed" $(kb2mb $memory_total_freed) "Mb" $(permem $memory_total_freed);
  printf " \u2551 ${bld}${wht}%-20s${rst} ${bld}${gre}%'11.02f${rst} ${wht}%-3s${rst} %3d%%  \u2502\n" "Ending Free Memory" $(kb2mb $memory_free_post) "Mb" $(permem $memory_free_post);
fi

# print bottom border
printf " \u2559"; for x in `seq 1 44`; do printf "\u2500"; done; printf "\u2518\n\n";

# good housekeeping seal of approval
unset red gre gry yel blu pur hil wht bld rst;
unset status_only memory_total memory_cached_pre memory_free_pre memory_buffers memory_free_post memory_total_freed memory_active memory_active_anon;

exit 0;
