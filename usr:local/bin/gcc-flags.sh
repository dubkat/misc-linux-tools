#!/bin/bash
# print the full gcc command if -march=native is used.
# Copyleft (L) Dan Reidy <dubkat+github@gmail.com>

optimize="-O2"

host=;
if hash rpm 2>/dev/null; then
    host="$(rpm -E %_host)"
    if hash ${host}-gcc 2>/dev/null; then
        gcc_cmd="${host}-gcc"
    else
        gcc_cmd="$(rpm -E %__cc)"
    fi
    gcc_optimize="$(rpm -E %optflags | sed -e 's/-D_FORTIFY[^ ]* //g' -e 's/-fstack-[^ ]* //g' -e 's/-O[^ ]* //g' -e 's/-g[^ ]* //' -e 's/-m[^ ]* //g') $optimize"

elif hash gcc 2>/dev/null; then
    gcc_cmd="gcc";
    gcc_optimize="$CFLAGS $optimize"
else
    echo "No GCC in your path. Is it even installed?";
    exit 1;
fi

gcc_stack_protector="-fPIE -pie -fstack-protector-strong"
gcc_fortify="-D_FORTIFY_SOURCE=2"

# if (($#)); then
#    stack_protector=
#    case $1 in
# 	all ) stack_protector="-fstack-protector-all";
# 	;;
# 	strong ) stack_protector="-fstack-protector-strong";
# 	;;
# 	default ) stack_protector="-fstack-protector";
# 	;;
# 	none ) stack_protector="-fno-stack-protector";
# 	;;
# 	* ) echo "Using System GCC Spec Default for stack-protector";
# 	    stack_protector=""
# 	;;
#   esac
#   echo "using $stack_protector"
#   shift
# fi
#
# if (($#)); then
#   case $1 in
#     0 ) optimize="-O0 -pipe"; ;;
#     1 ) optimize="-O1 -pipe"; ;;
#     2 ) optimize="-O2 -pipe"; ;;
#     3 ) optimize="-O3 -pipe"; ;;
#     4 ) optimize="-Ofast -pipe"; ;;
#     g ) optimize="-Og -pipe"; ;;
#   esac
#   shift
# fi

#echo
#echo "Testing OptFlags:         '$gcc_optimize'"
#echo "Testing Hardening Flags:  '$gcc_stack_protector'"
#echo "                          '$gcc_fortify'"
#echo

with_mno=$(
    "${gcc_cmd}" ${gcc_optimize} ${gcc_stack_protector} -march=native -mtune=native -v -E - < /dev/null 2>&1 |
    grep cc1 |
    perl -pe 's/^.* - //g;'
)
without_mno=$(echo "${with_mno}" | perl -pe 's/ -mno-\S+//g;')

"${gcc_cmd}" ${with_mno}    -dM -E - < /dev/null > /tmp/gcctest.a.$$
"${gcc_cmd}" ${without_mno} -dM -E - < /dev/null > /tmp/gcctest.b.$$

if diff -u /tmp/gcctest.{a,b}.$$; then
    echo "${without_mno} -pipe"
else
    echo "${with_mno} -pipe"
fi

rm /tmp/gcctest.{a,b}.$$

