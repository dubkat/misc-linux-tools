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

# calling this script will always kill any running urxvt daemon before relaunching.
pid=`pgrep urxvtd`
if [ $pid ]; then
  kill -u $USER -KILL $pid >/dev/null 2>&1
fi

test -x /usr/bin/urxvtd-256color && \
    /usr/bin/urxvtd-256color -f -q -o && \
    exit $?

test -x /usr/bin/urxvtd && \
    /usr/bin/urxvtd -f -q -o && \
    exit $?

exit 1
