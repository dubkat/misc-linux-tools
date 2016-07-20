#!/usr/bin/env bash
# easily convert a directory (and subdirectories) of images to webp format.
# Copyright (C) 2016 Dan Reidy <dubkat@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

## quality factor (0:small..100:big)
webp_quality=100

## encode image losslessly
# webp_lossless=0

## use near-lossless image preprocessing (0..100=off)
#webp_near_lossless=0

## <string> ..... comma separated list of metadata to
##                copy from the input to the output if present.
##                Valid values: all, none (default), exif, icc, xmp
webp_metadata="all"


## resize to Google Photos dimensions for their free image hosting.
#  2048x2048 [1:yes/0:no]
google_photos=1

## primary type of images being processed?
## photo, picture, or graph
webp_hint="picture"

## end of conversion command
eoc_rm_orig=0

eoc_mv_orig=1
eoc_mv_orig_dest="/tmp/orginals"

eoc_mv_new=0
eoc_mv_new_dest=""



# end of options

me=$(basename $0);

cc_y=
cc_r=
cc_g=
cc_b=
cc_m=
cc_w=
cc_bold=
cc_reset=
cc_ital=
cc_nital=

set_colors() {
	local ccolors=$(tput colors);
	cc_bold=$(tput bold);
	cc_reset=$(tput sgr0);
	cc_ital=$(tput sitm);
	cc_nital=$(tput ritm);
	case $ccolors in
		256 ) cc_y=$(tput setaf 226); cc_r=$(tput setaf 197); cc_g=$(tput setaf 154); cc_b=$(tput setaf 153); cc_m=$(tput setaf 169); cc_w=$(tput setaf 231); ;;
		 88 ) cc_y=$(tput setaf 77);  cc_r=$(tput setaf 64);  cc_g=$(tput setaf 60);  cc_b=$(tput setaf 43);  cc_m=$(tput setaf 65);  cc_w=$(tput setaf 79); ;;
		 16 ) cc_y=$(tput setaf 11);  cc_r=$(tput setaf 9);   cc_g=$(tput setaf 10);  cc_b=$(tput setaf 12);  cc_m=$(tput setaf 13);  cc_w=$(tput setaf 15); ;;
	esac
}

stout() {
	res=$?
	case $res in
		0 ) echo -e "\t${cc_g}$(tput smso)▒▒Done▒▒$(tput rmso)${cc_reset}"; ;;
		* ) echo -e "\t${cc_r}$(tput smso)▒▒Done▒▒$(tput rmso)${cc_reset}"; ;;
	esac
}
info() {
	echo -e " ${cc_b}*${cc_reset} ${cc_w}${@}${cc_reset}";
}
good() {
	echo -e " ${cc_g}*${cc_reset} ${cc_w}${@}${cc_reset}";
}
warn() {
	echo -e " ${cc_y}*${cc_reset} ${cc_w}${@}${cc_reset}";
}
error() {
	echo -e " ${cc_r}*${cc_reset} ${cc_w}${@}${cc_reset}";
}
fatal() {
	error $*
	exit 1
}

dim_h() {
	file=$1
	h=$(exiftool -s3 -ImageHeight $file);
	echo -n $h
}

dim_w() {
	file=$1
	w=$(exiftool -s3 -ImageWidth $file);
	echo -n $w
}

newsize() {
	w=$1
	h=$2
	if [ $w -gt $h ]; then
		echo -n "2048 0"
	elif [ $h -gt $w ]; then
		echo -n "0 2048"
	else
		echo -n "2048 2048"
	fi
}

compute_webp_args() {
	local file=$1

	local webp_opts="-preset ${webp_hint} -metadata all -m 6 -pass 3"
	if [ ${#webp_lossless} = 0 ] || [ "x$webp_lossless" = "x0" ]; then
		if [ ${#webp_quality} -gt 0 ] && [ $webp_quality -gt 0 ]; then
			webp_opts+=" -q $webp_quality -jpeg_like "
		fi
		if [ ${#webp_near_lossless} -gt 0 ] && [ $webp_near_lossless -lt 100 ]; then
			webp_opts+=" -near_lossless $webp_near_lossless ";
		fi
	else
		webp_opts+=" -lossless -z 9"
	fi

	if [ ${#webp_metadata} -gt 0 ]; then
		webp_opts+=" -metadata ${webp_metadata} "
	fi

	if [ ${#google_photos} -gt 0 ] && [ ${google_photos} -gt 0 ]; then
		local width=$(dim_w $file);
		local height=$(dim_h $file);
		if [ $width -gt 2048 ] || [ $height -gt 2048 ]; then
			local resize="$(newsize $width $height)"
			good "Resizing $width $height to $resize"
			webp_opts+=" -resize $resize "
		fi
	fi
	echo -n "${webp_opts}"
}

set_colors

if [ ${#@} -eq 0 ]; then
	error >&2 "${cc_bold}usage:${cc_reset}\t${cc_b}$me ${cc_m}${cc_ital}<directory>${cc_nital}${cc_reset}"
	error >&2 "${cc_reset}\t\tyou may wish to edit the script defaults at the"
	fatal >&2 "\t\t${cc_reset}top of this scipt, located at $0."

fi

if ! hash cwebp 2>/dev/null; then
	error "webp utils is not in your path."
	error "please install libweb-utils from your package manager, or from"
	fatal "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/index.html"
fi

while [ ${#@} -gt 0 ]; do
	arg=$1
	if [ -f "${arg}" ]; then
		webp_args="$(compute_webp_args ${arg})";
		info "Processing ${arg}"
		if [ "${arg##*.}" = "gif" ]; then
			gif2webp -o "${arg%%.*}.webp" "${arg}" || warn "gif2webp failed to process ${arg}";
		else
			cwebp -quiet $webp_args -o "${arg%%.*}.webp" "${arg}" || fatal "cwebp exited with errors."
		fi
	elif [ -d "${arg}" ]; then
		for file in $(find "${arg}" -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png"  -o -iname "*.tiff" -o -iname "*.tif" -type f ); do
			#echo "FILE: $file"
			if [ ! -f "${file}" ]; then
				warn "No such file ${file}: is there a space in the directory names?"
				continue;
			fi
			if [ -f "${file%.*}.webp" ]; then
				warn "Already Exists: ${file%.*}.webp"
				continue;
			fi
			webp_args="$(compute_webp_args ${file})"
			info "Processing ${cc_m}${file}${cc_reset}"
			if [ "${arg##*.}" = "gif" ]; then
				gif2webp -o "${file%.*}.webp" "${file}" >/dev/null 2>&1
			else
				cwebp -quiet $webp_args -o "${file%.*}.webp" "${file}" >/dev/null 2>&1
			fi
			stout

			touch -r "${file}" "${file%.*}.webp"

			if [ ${eoc_mv_new} -gt 0 ] && [ ${#eoc_mv_new_dest} -gt 0 ]; then
				info "Moving new WebP image to $eoc_mv_new_dest"
				new="${file%.*}.webp"
				test -d "${eoc_mv_new_dest}" || mkdir -p "${eoc_mv_new_dest}" || { echo && fatal "failed to create destination."; }
				mv "$new" "$eoc_mv_new_dest"
				stout
			elif [ ${eoc_mv_orig} -gt 0 ] && [ ${#eoc_mv_orig_dest} -gt 0 ]; then
				info "Moving old image to $eoc_mv_orig_dest"
				test -d "${eoc_mv_orig_dest}" || mkdir -p "${eoc_mv_orig_dest}" || { echo && fatal "failed to create destination."; }
				mv "$file" "$eoc_mv_orig_dest"
				stout
			elif [ ${eoc_rm_old} -gt 0 ]; then
				info "delting orginal file: $file"
				rm "${file}"
				stout
			fi

		done
	fi
	shift
done
