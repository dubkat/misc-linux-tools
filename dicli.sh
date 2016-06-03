#!/bin/bash
#
# dicli.sh - Listen to Digitally Imported FM without the premium membership
# Copyleft (C) 2016 Dan Reidy <dubkat@gmail.com>
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.


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

station[0]="00 Club Hits";	 				staturl[0]="di_00sclubhits_aac";
station[1]="Ambient"; 							staturl[1]="di_ambient_aac";
station[2]="Atmospheric Breaks"; 		staturl[2]="di_atmosphericbreaks_aac"
station[3]="Bassline";							staturl[3]="di_bassline_aac";
station[4]="Bass & Jackin House";		staturl[4]="di_bassnjackinhouse_aac";
station[5]="Big Beat";							staturl[5]="di_bigbeat_aac";
station[6]="Big Room House";				staturl[6]="di_bigroomhouse_aac";
station[7]="Breaks";								staturl[7]="di_breaks_aac";
station[8]="ChillHop";							staturl[8]="di_chillhop_aac";
station[9]="Tropical House";				staturl[9]="di_chillntropicalhouse_aac";
station[10]="Chillout";							staturl[10]="di_chillout_aac";
station[11]="Chillout Dreams";			staturl[11]="di_chilloutdreams_aac";
station[12]="Chill Step";						staturl[12]="di_chillstep_aac";
station[13]="Classic Euro Dance";		staturl[13]="di_classiceurodance_aac";
station[14]="Classic Euro Disco";		staturl[14]="di_classiceurodisco_aac";
station[15]="Classic Trance";				staturl[15]="di_classictrance_aac";
station[16]="Classic Vocal Trance";	staturl[16]="di_classicvocaltrance_aac";
station[17]="Club Dub Step";				staturl[17]="di_clubdubstep_aac";
station[18]="Club Sounds";					staturl[18]="di_clubsounds_aac";
station[19]="Dark D-n-B";						staturl[19]="di_darkdnb_aac";
station[20]="Dark PsyTrance";				staturl[20]="di_darkpsytrance_aac";
station[21]="Deep House";						staturl[21]="di_deephouse_aac";



function print_usage {
	self=$(basename $0);
	echo "Usage:"
	echo -e "\t$self list      - display a list of configured stations."
	echo -e "\t$self play <ID> - get the ID from list."
	echo

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

	local url="${diurl}/${staturl[$id]}?1"

	header
	if hash xcvlc 2>/dev/null; then
		cvlc $url --http-user-agent="'${agent}'"
	elif hash mplayer 2>/dev/null; then
		mplayer -user-agent "${agent}" $url 2>/dev/null
	elif hash mplayer2 2>/dev/null; then
		mplayer2 -user-agent="${agent}" $url 2>/dev/null
	elif hash mpv 2>/dev/null; then
		mpv --terminal --no-video --user-agent="${agent}" $url 2>/dev/null
	else
		echo "Error: please install either vlc, mplayer, mplayer2, or mpv" >&2
		exit 1
	fi

	exit $?
}

case $1 in
	list ) list_stations; ;;
	play ) shift; play_station $1; ;;

	* ) print_usage; exit 1; ;;
esac
