 #!/bin/bash

# automatically use the best rxvt daemon

# urxvtd           urxvtd-256color

# no need to get fancy....

killall -u $USER -KILL urxvtd 2>&1 >/dev/null
killall -u $USER -KILL urxvtd-256color 2>&1 >/dev/null

test -x /usr/bin/urxvtd-256color && \
    /usr/bin/urxvtd-256color -f -q -o && \
    exit $?

test -x /usr/bin/urxvtd && \
    /usr/bin/urxvtd -f -q -o && \
    exit $?

exit 1

