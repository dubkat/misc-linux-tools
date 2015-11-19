#!/bin/bash
# (L) 2014 Dan Reidy <dubkat@gmail.com>
# cruddy, badly written script to show terminal color codes
# License: WTFPL (do what the fuck you want, public license)
# note: depends on figlet, colout, and obviously ncurses
# http://github.com/dubkat/misc-linux-tools
#

function footer {
	local str=
	for x in `seq 0 $[COLUMNS / 2]`; do
        	printf -v str "%s=" $str
	done

        echo $str | colout '.' Spectrum bold
}

hcolor=220
jump=5
start=

figlet -f mini -c "~~Terminal $(tput colors) Color Pallet~~" | colout '([\/\)])|([\)\(`\-_\|])|([.o])' Rainbow,Rainbow,Rainbow bold,bold,blink
footer;

echo; echo;
echo -en "$(tput setaf $hcolor)$(tput bold)" 
figlet -f term -c "[[ Basic 8 colors ]]"
echo -e "$(tput sgr0)"
footer;
echo

echo -n "     "
for x in `seq 1 8`;
do
	printf "%s### %03d ###%s" $(tput setaf $x) $x $(tput sgr0)
	start=$[x + 1]
done
echo
echo -n "     "
for x in `seq 9 16`; do
	printf "%s### %03d ###%s" $(tput setaf $x) $x $(tput sgr0)
	start=$[x + 1]
done
echo

start=17

colors=$(tput colors)
echo;echo;
echo -en "$(tput setaf $hcolor)$(tput bold)" 
figlet -f term -c "[[ Extended $colors color Pallet ]]"
echo -e "$(tput sgr0)"
footer;
echo
echo -n "     "
for x in `seq $start $colors`; do
	if [ $x = 232 ]; then
		break
	fi
	printf "%s### %03d ###%s | " $(tput setaf $x) $x $(tput sgr0)
	if [ `expr $x % $jump` = 1 ]; then
		#x=$[start + $x]
		echo
		echo -n "     "
	fi
done
echo; echo;
echo -en "$(tput setaf $hcolor)$(tput bold)"
figlet -f term -c "[[ Gray Scale ]]"
echo -e "$(tput sgr0)"
footer;
echo

start=232;
row=0
echo -n "                 "
for x in `seq $start $[colors - 1]`; do
	if test $row = 20; then echo; footer; echo; exit 0; fi
	for y in `seq 0 4`; do
		if [ $[x + y] = $colors ]; then
			# be happy
			echo
			break 2;
		fi
		printf "%s###%03d###%s" $(tput setaf $[x + y]) $[x + y]  $(tput sgr0)
	done
	x=$[x + y]
	row=$[row + 1]
	echo
	echo -n "                 "
done
