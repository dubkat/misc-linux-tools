#!/bin/bash

# automatically use the best rxvt client
# fallback to the basic standalone if available

# urxvtc           urxvtc-256color 
# urxvt            urxvt-256color

RXVTC="/bin/false"

for x in urxvtc-256color urxvtc urxvt-256color urxvt; 
do
    test -x "/usr/bin/${x}" && exec /usr/bin/${x} && exit $?
done


