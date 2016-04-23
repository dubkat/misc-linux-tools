#!/bin/bash
# print the full gcc command if -march=native is used.
# Copyleft (L) Dan Reidy <dubkat+github@gmail.com>

optimize="-O2 -pipe"

if hash rpm 2>/dev/null; then
    if hash $(rpm -E %{_target_platform}%{?_gnu}-gcc) 2>/dev/null; then
        gcc_cmd=$(rpm -E %{_target_platform}%{?_gnu}-gcc);
    else
        gcc_cmd=$(rpm -E %__cc);
    fi
    optimize="$(rpm -E %optflags | sed -e 's/-fstack-[^ ]* //g' -e 's/-O[^ ]* //g' -e 's/-g[^ ]* //' -e 's/-m[^ ]* //g') $optimize"
elif hash gcc 2>/dev/null; then
    gcc_cmd="gcc";
else
    echo "No GCC in your path. Is it even installed?";
    exit 1;
fi

stack_protector="-D_FORTIFY_SOURCE=2 -fPIC -fPIE -fstack-protector-strong"


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
    "${gcc_cmd}" ${optimize} ${stack_protector} -march=native -mtune=native -v -E - < /dev/null 2>&1 |
    grep cc1 |
    perl -pe 's/^.* - //g;'
)
without_mno=$(echo "${with_mno}" | perl -pe 's/ -mno-\S+//g;')

"${gcc_cmd}" ${with_mno}    -dM -E - < /dev/null > /tmp/gcctest.a.$$
"${gcc_cmd}" ${without_mno} -dM -E - < /dev/null > /tmp/gcctest.b.$$

if diff -u /tmp/gcctest.{a,b}.$$; then
    echo "Safe to strip -mno-* options." >/dev/stderr
else
    echo "WARNING! Some -mno-* options are needed!" >/dev/stderr
fi

rm /tmp/gcctest.{a,b}.$$

echo "${gcc_cmd}: ${without_mno}"
