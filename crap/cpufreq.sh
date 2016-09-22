#!/bin/sh

# modprobe cpufreq_conservative cpufreq_powersave

if [ $UID -gt 0 ]; then
    if ! id -G -n | grep -Eq '\b(wheel|root|adm)\b'; then
        echo "You are not a super-user." >&2
        exit 1
    fi
fi


case $1 in

    conservative|con )
        sudo modprobe cpufreq_conservative 2>/dev/null
        sudo cpupower frequency-set -g conservative
        cpupower frequency-info
        ;;

    powersave|pow )
        sudo modprobe cpufreq_powersave 2>/dev/null
        sudo cpupower frequency-set -g powersave
        cpupower frequency-info
        ;;

    ondemand|ond|default|def )
        sudo modprobe cpufreq_ondemand 2>/dev/null
        sudo cpupower frequency-set -g ondemand
        cpupower frequency-info
        ;;

    performance|per )
        sudo modprobe cpufreq_performance 2>/dev/null
        sudo cpupower frequency-set -g performance
        cpupower frequency-info
        ;;

    * )
        cpupower frequency-info
        echo
        echo "$(basename $0) <default|performance|ondemand|powersave|conservative>"
        echo "note: default is equivlent to ondemand."
        echo "modes may be abreviated with the first 3 letters, such as pow for powersave."
        false;
        ;;
esac

exit $?
