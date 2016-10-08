#!/usr/bin/env bash
#   Copyright (C) 2016 Dan Reidy <dubkat@gmail.com>                            #
#   Command Line Package Queue for zypper / openSUSE                           #
#                                                                              #
#   This program is free software; you can redistribute it and/or modify       #
#   it under the terms of the GNU General Public License as published by       #
#   the Free Software Foundation; either version 2 of the License, or          #
#   (at your option) any later version.                                        #
#                                                                              #
#   This program is distributed in the hope that it will be useful,            #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#   GNU General Public License for more details.                               #
#                                                                              #
#   You should have received a copy of the GNU General Public License          #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.      #
#                                                                              #
#                    ⢀⡀ ⣀⡀ ⢀⡀ ⣀⡀ ⢎⡑ ⡇⢸ ⢎⡑ ⣏⡉
#                    ⠣⠜ ⡧⠜ ⠣⠭ ⠇⠸ ⠢⠜ ⠣⠜ ⠢⠜ ⠧⠤



function zypp_check() {
  if ! hash zypper 2>/dev/null; then
    echo "This script is intended for use on SUSE Linux." >&2
    echo "If this is a SUSE Linux based distro, make sure zypper is in your path." >&2
    return 127
  fi
}

function zroot_check() {
  if [ $UID -gt 0 ]; then
    echo "You must be root to use these commands."
    return 1;
  fi
}

function zypp_squash() {
  if [ -n "$ZYPP_QUEUE" ]; then
    export ZYPP_QUEUE="$(echo $ZYPP_QUEUE | tr ' ' '\n' | sort | uniq | tr '\n' ' ')";
  fi
}

function show_zqueue() {
  if [ -z "$ZYPP_QUEUE" ]; then
    echo "The zypper queue is currently empty."
    return 0
  fi
  zypp_squash
  echo "$(tput setaf 87)*$(tput sgr0) Package Queue: $ZYPP_QUEUE"
  return 0
}

function zqueue() {
  export ZYPP_QUEUE+=" $@";
}

function reset_zqueue() {
  unset ZYPP_QUEUE;
}

function run_zqueue() {
  zroot_check
  zypp_check
  zypp_squash
  echo "$(tput setaf 87)*$(tput sgr0) Updating Zypp Repos.";
  zypp-refresh || { exit $?; }

  zypper install $ZYPP_QUEUE && reset_zqueue
  return $?
}
