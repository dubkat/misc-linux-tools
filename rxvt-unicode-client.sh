#!/bin/bash
# automatically use the best rxvt daemon
# Copyright (C) 2014-2015 Dan Reidy <dubkat@gmail.com>, http://plus.google.com/+DanReidy
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#################################################################################
# automatically use the best rxvt client
# fallback to the basic standalone if available

# urxvtc           urxvtc-256color
# urxvt            urxvt-256color

# the daemon script should be in your path.
RXVT_DAEMON="rxvt-unicode-daemon.sh"

function start_server ()
{
  test `pgrep urxvtd` || $RXVT_DAEMON
}

function start_client ()
{
  for client in urxvtc-256color urxvtc; do
    test -x "/usr/bin/${client}" && exec "/usr/bin/${client}" && exit $?
  done
}

start_server;
start_client;

# if we got here, there's something not right.
for x in urxvt-256color urxvt; do
  test -x "/usr/bin/${x}" && exec "/usr/bin/${x}" && exit $?
done

err_msg="ERROR: rxvt-unicode-client.sh was unable to launch any terminal. is rxvt-unicode even installed?"
logger -t rxvt-unicode "$err_msg"
exit 99
