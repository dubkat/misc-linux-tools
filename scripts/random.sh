#!/bin/bash
# Copyright (C) 2014-2016 Dan Reidy <dubkat@gmail.com>
RANDOM_VERSION=16.06.04

do_version() {
        SSL_VER="$(openssl version)"
        echo "random.sh - Generate secure random generated strings with no hassle."
        echo "* Copyright 2014-$(date +%Y) Dan Reidy <dubkat@gmail.com>"
        echo "* https://github.com/dubkat/misc-linux-tools"
        echo "* Based on ${SSL_VER}"
        echo "* random.sh v${RANDOM_VERSION}"
}

do_short() { echo $RANDOM_VERSION; }

do_usage() {
        ret=$1
        if [ $ret -gt 0 ]; then
                do_version;
        fi
        echo
        echo "Usage:"
        echo "\$ $(basename $0) [192|224|256|384|512|all]" >&2
        echo "\$ $(basename $0) --version" >&2
        echo "\$ $(basename $0) --help" >&2
        echo "# Example: $(basename $0) 256 > keyfile" >&2
        echo "# This will generate a 256 bit string WITHOUT a new-line inside 'keyfile'" >&2
        echo "# ...perfect for generating a LUKS pass." >&2
        return $ret
}

do_192() {
	echo "Generating cryptographically secure 192bit pass key" >&2
	openssl rand -base64 48 | cut -b1-24 | tr -d '\n'
        echo >&2
}

do_224() {
	echo "Generating cryptographically secure 224bit pass key" >&2
	openssl rand -base64 48 | cut -b1-28 | tr -d '\n'
        echo >&2
}

do_256() {
	echo "Generating cryptographically secure 256bit pass key" >&2
	openssl rand -base64 48 | cut -b1-32 | tr -d '\n'
        echo >&2
}

do_384() {
	echo "Generating cryptographically secure 384bit pass key" >&2
	openssl rand -base64 48 | cut -b1-48 | tr -d '\n'
        echo >&2
}

do_512() {
	echo "Generating cryptographically secure 512bit pass key" >&2
	openssl rand -base64 48 | tr -d '\n'
        echo >&2
}

do_all() {
	do_192; do_224; do_256; do_384; do_512;
}

case $1 in
	192 ) do_192;
        ;;
	224 ) do_224;
        ;;
	256 ) do_256;
        ;;
	384 ) do_384;
        ;;
	512 ) do_512;
        ;;
	all ) do_all;
        ;;

        -v|--version )
              do_version;
        ;;
        -s|--short-version )
             do_short;
        ;;
        -h|--help )
             do_usage 0;
        ;;

        * )
             do_usage 1;
        ;;
esac

exit $?
