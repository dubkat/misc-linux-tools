#!/bin/bash

#gcc_cmd="x86_64-pc-linux-gnu-gcc"
gcc_cmd="${CPU}-suse-linux-gnu-gcc"
optimize="-O2 -pipe"
stack_protector="-fstack-protector-strong"

# Optionally supply path to gcc as first argument
if (($#)); then
    gcc_cmd="$1"
    shift
fi
#
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

with_mno=$(
    "${gcc_cmd}" -march=native -mtune=native ${optimize} ${stack_protector} -v -E - < /dev/null 2>&1 |
    grep cc1 |
    perl -pe 's/^.* - //g;'
)
without_mno=$(echo "${with_mno}" | perl -pe 's/ -mno-\S+//g;')

"${gcc_cmd}" ${with_mno}    -dM -E - < /dev/null > /tmp/gcctest.a.$$
"${gcc_cmd}" ${without_mno} -dM -E - < /dev/null > /tmp/gcctest.b.$$

if diff -u /tmp/gcctest.{a,b}.$$; then
    echo "Safe to strip -mno-* options."
else
    echo
    echo "WARNING! Some -mno-* options are needed!"
    exit 1
fi

rm /tmp/gcctest.{a,b}.$$

echo "${gcc_cmd}" "${without_mno}"
