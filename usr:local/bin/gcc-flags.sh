#!/bin/bash
# print the full gcc command if -march=native is used.
# Copyleft (L) Dan Reidy <dubkat+github@gmail.com>
GCCFLAGS_VERSION=16.06.9

host="";
gcc_optimize="";

test_stack() {
	local stack_list="-fstack-protector-strong -fstack-protector -fno-stack-protector";
	for flag in $stack_list; do
		if ${gcc_cmd} -O2 $flag -v -E - < /dev/null >/dev/null 2>&1; then
			echo -n "$flag"
			break;
		fi
	done
}

gccflags_version() {
	echo "$GCCFLAGS_VERSION"
	exit 0
}

generate_flags() {
	host="$(gcc -dumpmachine)"
	gcc_optimize=""

	if hash ${host}-gcc 2>/dev/null; then
	        gcc_cmd="${host}-gcc"
	elif hash ${host}-gnu-gcc 2>/dev/null; then
		gcc_cmd="${host}-gnu-gcc"
	else
        	gcc_cmd="gcc"
	fi

	if hash rpm 2>/dev/null; then
	    gcc_optimize="$(rpm -E %optflags | sed -e 's/-D_FORTIFY[^ ]* //g' -e 's/-fstack-[^ ]* //g' -e 's/-O[^ ]* //g' -e 's/-g[^ ]* //' -e 's/-m[^ ]* //g') $optimize"
	elif hash gcc 2>/dev/null; then
	    gcc_optimize="-O2 -funwind-tables -fasynchronous-unwind-tables"
	fi

	gcc_stack_protector="-fPIE -pie "
	gcc_fortify="-D_FORTIFY_SOURCE=2"
	gcc_stack_protector+="$(test_stack)"



	if [ "$1" = "debug" ]; then
		echo >&2
		echo "Testing OptFlags:         '$gcc_optimize'" >&2
		echo "Testing Hardening Flags:  '$gcc_stack_protector'" >&2
		echo "                          '$gcc_fortify'" >&2
		echo >&2
	fi

	with_mno=$(
	    "${gcc_cmd}" ${gcc_optimize} ${gcc_stack_protector} ${gcc_fortify} -march=native -mtune=native -v -E - < /dev/null 2>&1 |
	    grep cc1 |
	    perl -pe 's/^.* - //g;'
	)
	without_mno=$(echo "${with_mno}" | perl -pe 's/ -mno-\S+//g;')

	"${gcc_cmd}" ${with_mno}    -dM -E - < /dev/null > /tmp/gcctest.a.$$
	"${gcc_cmd}" ${without_mno} -dM -E - < /dev/null > /tmp/gcctest.b.$$

	echo "export CC='$gcc_cmd'"
	echo "export CPPFLAGS='$gcc_fortify'"
	
	if diff -u /tmp/gcctest.{a,b}.$$; then
	    echo "export CFLAGS='${without_mno} -pipe'"
	else
	    echo "export CFLAGS='${with_mno} -pipe'"
	fi

	rm /tmp/gcctest.{a,b}.$$
}


case $1 in
	--version|-v )
		gccflags_version;
		;;
	* )
		generate_flags;
		;;
esac

