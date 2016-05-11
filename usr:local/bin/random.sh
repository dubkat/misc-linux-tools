#!/bin/bash
# Copyright (C) 2014-2016 Dan Reidy <dubkat@gmail.com>

do_192() {
	echo "Generating cryptographically secure 192bit pass key" >&2
	openssl rand -base64 48 | cut -b1-24 | tr -d '\n'
}

do_224() {
	echo "Generating cryptographically secure 224bit pass key" >&2
	openssl rand -base64 48 | cut -b1-28 | tr -d '\n'
}

do_256() {
	echo "Generating cryptographically secure 256bit pass key" >&2
	openssl rand -base64 48 | cut -b1-32 | tr -d '\n'
}

do_384() {
	echo "Generating cryptographically secure 384bit pass key" >&2
	openssl rand -base64 48 | cut -b1-48 | tr -d '\n'
}

do_512() {
	echo "Generating cryptographically secure 512bit pass key" >&2
	openssl rand -base64 48 | tr -d '\n'
}

do_all() {
	do_192; do_224; do_256; do_384; do_512;
}

case $1 in
	192 ) do_192; ;;
	224 ) do_224; ;;
	256 ) do_256; ;;
	384 ) do_384; ;;
	512 ) do_512; ;;
	all ) do_all; ;;
	* )
		echo "$(basename $0) [192|224|256|384|512|all]" >&2
		echo "example: $(basename $0) 256 > outfile" >&2
		exit $1
esac

exit $?
