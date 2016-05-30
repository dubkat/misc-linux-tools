#!/bin/bash

# dicli.sh - Listen to Digitally Imported FM without the premium membership
# (C) 2016 Dan Reidy <dubkat@gmail.com>


function header() {
echo "$(tput setaf 81)"
cat<<HEAD
	$(tput setaf 111)╺┳┓╻┏━╸╻╺┳╸┏━┓╻  ╻  ╻ ╻$(tput setaf 255)╻┏┳┓┏━┓┏━┓┏━┓╺┳╸┏━╸╺┳┓
	$(tput setaf 111) ┃┃┃┃╺┓┃ ┃ ┣━┫┃  ┃  ┗┳┛$(tput setaf 255)┃┃┃┃┣━┛┃ ┃┣┳┛ ┃ ┣╸  ┃┃
	$(tput setaf 111)╺┻┛╹┗━┛╹ ╹ ╹ ╹┗━╸┗━╸ ╹ $(tput setaf 255)╹╹ ╹╹  ┗━┛╹┗╸ ╹ ┗━╸╺┻┛
HEAD
echo "$(tput sgr0)"
}

declare -A station;
declare -A staturl;
declare -r diurl="http://pub7.di.fm"
declare -r agent="AudioAddict-di/3.2.0.3240 Android/5.1"
#http://pub7.di.fm/di_ambient_aac?1 -user-agent "AudioAddict-di/3.2.0.3240 Android/5.1"

station[0]="00 Club Hits"
staturl[0]="di_00sclubhits_aac"
station[1]="Ambient"
staturl[1]="di_ambient_aac"
station[2]="Atmospheric Breaks"
staturl[2]="di_atmosphericbreaks_aac"
station[3]="Bassline"
staturl[3]="di_bassline_aac"

function print_usage {
	echo "suck it."
}

function list_stations {
	local i=0;
	local fmt;
	local bold=$(tput bold)
	local rest=$(tput sgr0)
	local orng=$(tput setaf 178);
	printf -v fmt "  %s%s%%-5s  %s%%s\n" $orng $bold $rest
	printf "$fmt" "Id" "Name";
	while [ 1 ]; do
		printf "$fmt" $i "${station[$i]}";
		i=$[i + 1];
		if [ -z "${station[$i]}" ]; then
			break
		fi
	done
}

function play_station {
	id=$1;
	if [ -z "$id" ]; then
		print_usage;
		exit 1;
	fi

	header
	mpv 	--terminal \
		--term-osd force \
		--user-agent="$agent" \
		--term-playing-msg="${station[$id]}" \
		${diurl}/${staturl[$id]}?1 2>/dev/null
}

case $1 in
	list ) list_stations; ;;
	play ) shift; play_station $1; ;;
	
	* ) print_usage; exit 1; ;;
esac


