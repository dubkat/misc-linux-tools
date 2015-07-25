#!/usr/bin/env bash
#
# suse-fetch.sh - Fetch the current version of openSUSE Tumbleweed
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
#
# Version: 2015062200

# all iso's come as an x86_64, however not all come as x86_32, here's the breakdown:
# i586: DVD, NET
# i686: GNOME-Live, KDE-Live, Rescue-CD
# x86_64: All the above.
# This can be a space seperated list.
wanted_arch="x86_64"

# Which image flavor do we want, this can be a space seperated list
wanted_flavor="KDE-Live"

# Where do we save the results
save_prefix="/Users/dubkat/ISOs"

# The mirror and path where we will find our ISO.
#suse_mirror="http://mirrors.us.kernel.org/opensuse/factory/iso"
suse_mirror="http://opensuse.temple.edu/factory/iso/"

# end of settings
########################################

fetcher=
options=

#checked in order...
prefered_fetchers="aria2c wget"

wget_options="--no-http-keep-alive --no-cookies --directory-prefix=\"${save_prefix}\"
--continue --show-progress --trust-server-names --timestamping"

aria2_options=""

# probably broken
for x in $prefered_fetchers; do
  if [ -x "`which $x`" ]; then
    fetcher="`which $x`"
    options="${${x}_options}"
    break;
  fi
done




# stop, hammer time!
for arch in $wanted_arch; do
  for flavor in $wanted_flavor; do

    "${suse_mirror}/openSUSE-Tumbleweed-${flavor}-${arch}-Current.iso"
  done
done
