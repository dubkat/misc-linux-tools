#!/usr/bin/env bash
# dprompt.sh - dubkat's HUD command prompt for 256color terminals
# Copyleft (L) 2015 Dan Reidy <dubkat@gmail.com>

# Settings:
# dont change the settings here, instead  but them in your bashrc and export them
# then call this script after.

### SET THESE IN YOUR .bashrc BEFORE CALLING THIS SCRIPT.
### NOT HERE IN THE SCRIPT.
### Example .bashrc
### declare -A PROMPT_DUBKAT # it's an array, not a regular variable. so declare it as such
### export PROMPT_DUBKAT['USERCOLOR']=38     # export the setting (this example is aqua)
### export PROMPT_DUBKAT['HOSTCOLOR']=129    # export the setting (this example is purple)
###                                          # see the colortest script for options 


### From the bash 4.3 manpage
# PROMPTING
#        When executing interactively, bash displays the primary prompt PS1 when it is ready to read a command, and the secondary prompt PS2 when it needs more input to com-
#        plete a command.  Bash allows these prompt strings to be customized by inserting a number of backslash-escaped special characters that are decoded as follows:
#               \a     an ASCII bell character (07)
#               \d     the date in "Weekday Month Date" format (e.g., "Tue May 26")
#               \D{format}
#                      the format is passed to strftime(3) and the result is inserted into the prompt string; an empty format results in a locale-specific  time  representa-
#                      tion.  The braces are required
#               \e     an ASCII escape character (033)
#               \h     the hostname up to the first `.'
#               \H     the hostname
#               \j     the number of jobs currently managed by the shell
#               \l     the basename of the shell's terminal device name
#               \n     newline
#               \r     carriage return
#               \s     the name of the shell, the basename of $0 (the portion following the final slash)
#               \t     the current time in 24-hour HH:MM:SS format
#               \T     the current time in 12-hour HH:MM:SS format
#               \@     the current time in 12-hour am/pm format
#               \A     the current time in 24-hour HH:MM format
#               \u     the username of the current user
#               \v     the version of bash (e.g., 2.00)
#               \V     the release of bash, version + patch level (e.g., 2.00.0)
#               \w     the current working directory, with $HOME abbreviated with a tilde (uses the value of the PROMPT_DIRTRIM variable)
#               \W     the basename of the current working directory, with $HOME abbreviated with a tilde
#               \!     the history number of this command
#               \#     the command number of this command
#               \$     if the effective UID is 0, a #, otherwise a $
#               \nnn   the character corresponding to the octal number nnn
#               \\     a backslash
#               \[     begin a sequence of non-printing characters, which could be used to embed a terminal control sequence into the prompt
#               \]     end a sequence of non-printing characters
#
#        The  command  number  and  the history number are usually different: the history number of a command is its position in the history list, which may include commands
#        restored from the history file (see HISTORY below), while the command number is the position in the sequence of commands executed during the current shell  session.
#        After  the  string  is  decoded,  it is expanded via parameter expansion, command substitution, arithmetic expansion, and quote removal, subject to the value of the
#        promptvars shell option (see the description of the shopt command under SHELL BUILTIN COMMANDS below).


function dprompt ()
{
	local EXIT="$?"
	local STATUS_MARK=""
	if [ -z $DPROMPT_VERSION ]; then
		readonly DPROMPT_VERSION="15.11.11"
		export DPROMPT_VERSION
	fi

	declare -a bool=( 'AUTOCLEAR' 'SHOWUNAME' 'SHOWRETURN' 'SHOWPATH' 'SHOWTERM' )

	# generate a random number between floor and ceiling
	function rand {
		local lower=$1
		local upper=$2
		echo -n $(($RANDOM % $upper + $lower))
	}

	function duptime {
		local uptime=
		local boottime=
		local unixtime=
		local reply=
		local hms=
		local bold=$(tput bold);

		if [ -r "/proc/uptime" ]; then
			uptime=$(</proc/uptime)
			uptime=${uptime%%.*}
		else
			boottime=$(sysctl -n kern.boottime | awk '{ print $4 }' | tr -d ',')
			unixtime=$(date "+%s")
			uptime="$(( $unixtime - $boottime ))"
		fi

		local seconds=$(( uptime%60 ))
		local minutes=$(( uptime/60%60 ))
		local hours=$(( uptime/60/60%24 ))
		local days=$(( uptime/60/60/24%7 ))
		local weeks=$(( uptime/60/60/24/7%52 ))
		local years=$(( uptime/60/60/24/7/52 ))
		reply=

		if [ $years -gt 1 ]; then
			reply+="\[${bold}\]${years}\[${bold}\] years, "
		elif [ $years -eq 1 ]; then
			reply+="\[${bold}\]${years}\[${bold}\] year, "
		fi

		if [ $weeks -gt 1 ]; then
			reply+="\[${bold}\]${weeks}\[${bold}\] weeks, "
		elif [ $weeks -eq 1 ]; then
			reply+="\[${bold}\]${weeks}\[${bold}\] week, "
		fi

		if [ $days -gt 1 ]; then
			reply+="\[${bold}\]${days}\[${bold}\] days, "
		elif [ $days -eq 1 ]; then
			reply+="${days} day, "
		fi

		printf -v hms "%02d:%02d:%02d" $hours $minutes $seconds
		reply+=$hms
		echo -n $reply
	}

	function loadcheck {
		local cores=
		local load=
		#if [ "$OS_KERN" = "Darwin" ];
		#then
		#	cores="$(sysctl -n machdep.cpu.cores_per_package)"
		#	load="$(sysctl -n vm.loadavg)"
	   	#	load_1="$(echo $load | awk '{ print $2 }')"
		#else
			cores="$(grep -c processor /proc/cpuinfo)"
			load="/usr/local/bin/loadavg | grep Relative: | awk '{ print $2 }'"
		#fi

		if hash colout 2>/dev/null; 
		then
			load="\[$(echo $load | colout -l 0,$cores '^(.*)$' Scale)\]"
		fi
		echo -n "$load"
	}


	function upper {
	    word=$1
	    char="`echo $word | cut -c1 | tr '[a-z]' '[A-Z]'`"
	    remain="`echo $word | cut -c1 --complement`"
	    echo -n "${char}${remain}"
	}
	
	# ripped from Gentoo.
	function yesno {
		local in=$1
		case $in in
			[1Yy]|[Yy][Ee][Ss]|[Oo][Nn]|[Ee]nabled|[Tt]rue)
				return $(true)
				;;
			[0Nn]|[Nn][Oo]|[Oo][Ff][Ff]|[Dd]isabled|[Ff]alse)
				return $(false)
				;;
			*)
				return -1
				;;
			esac
		}

	function r_code {
		# TODO: clean this up
		DUBKAT_PROMPT['RETURN_GOOD']="${DUBKAT_PROMPT['RETURN_GOOD']:-✓}"
		DUBKAT_PROMPT['RETURN_BAD']="${DUBKAT_PROMPT['RETURN_BAD']:-✗}"
		DUBKAT_PROMPT['RETURN_UNK']="${DUBKAT_PROMPT['RETURN_UNK']:-?}"

		function r_pos () { echo -n "\[$(tput setaf 118)\] \[${DUBKAT_PROMPT['RETURN_GOOD']}\[$(tput sgr0)\]"; }
		function r_neg () { echo -n "\[$(tput setaf 196)\] \[${DUBKAT_PROMPT['RETURN_BAD']}\[$(tput sgr0)\]"; }
		function r_unk () { echo -n "\[$(tput setaf 226)\] \[${DUBKAT_PROMPT['RETURN_UNK']}\[$(tput sgr0)\]"; }

		if [ ${EXIT} = 0 ]; then 
			printf "%03s $(r_pos)" "\[ \[ \[" 
		elif [ ${EXIT} = 1 ]; then 
			printf "\[$(tput setaf 196)\]%03d\[$(tput sgr0)\] $(r_neg)" ${EXIT} 
		else 
			printf "\[$(tput setaf 190)\]%03d\]$(tput sgr0)\] $(r_unk)" ${EXIT}
		fi
	}

	function pretty_date {
		local format=
		local a=$(tput setaf 45)
		local b=$(tput setaf 33)
		local day=$(date +%a)
		local mon=$(date +%b)
		local dom=$(date +%d)
		local h=$(date +%H)
		local m=$(date +%M)
		local s=$(date +%S)
        	local pretty_zone="${TZ##*/}"
		format="\[$b\]${pretty_zone}\[$b\]$sep\[$a\]$day\[$b\]$mon\[$a\]$dom \[$b\]$h\[$a\]:\[$b\]$m\[$a\]:\[$b\]${s}$(tput sgr0)"
		echo -n $format
	}
	
	function _dprompt_version {
		echo -n $DPROMPT_VERSION
	}
	function dprompt_version {
		echo "dubkat-shell-prompt v$DPROMPT_VERSION running on $OS_NAME $OS_VERSION"
		echo "Copyright (C) 2014-2015 Dan Reidy <dubkat@gmail.com>"
		echo "https://github.com/dubkat/misc-linux-tools"
	}
	

	
	local userhost="\[$(tput setaf ${PROMPT_DUBKAT['USERCOLOR']})\]\u"
	userhost+="\[$(tput setaf ${PROMPT_DUBKAT['MISCCOLOR']})\]@"
	userhost+="\[$(tput setaf ${PROMPT_DUBKAT['HOSTCOLOR']})\]\H"

	OS_NAME="${OS_NAME:-$(uname -o)}"
	OS_KERN="${OS_KERN:-$(uname -s)}"
	OS_KVER="${OS_KVER:-$(uname -r)}"
	
	if [ "${OS_KERN}" = "Darwin" ]; then
		if [ ! `hash sw_vers 2>/dev/null` ]; then
			OS_NAME="`sw_vers -productName`"
			OS_KVER="`sw_vers -productVersion`"
		fi
	fi
	if [ "${OS_KERN}" = "Linux" ]; then
	    if [ -r "/etc/os-release" ]; then
	        . /etc/os-release
	    fi
	    # get our distro's token ansi color
	    if [ ! -z ANSI_COLOR ];  then
	        DISTRO_COLOR="\e[${ANSI_COLOR}m\]"
	    else
	        DISTRO_COLOR="\[$(tput setaf ${PROMPT_DUBKAT['MISCCOLOR']})\]"
	    fi
	    OS="$NAME $VERSION"
	    OS_RELEASE_VERSION="$VERSION_ID"
	fi


	local bc=${PROMPT_DUBKAT['BRACKETCOLOR']}
	local lb="\[$(tput setaf $bc)\]{\[$(tput sgr0)\]"
	local rb="\[$(tput setaf $bc)\]}\[$(tput sgr0)\]"
	local sep="\[$(tput setaf ${PROMPT_DUBKAT['SEPCOLOR']})\]${PROMPT_DUBKAT['SEPERATOR']}\[$(tput sgr0)\]"
	PS1=
	
	# userhost
	PS1="${lb}${userhost}${rb}"
	PS1+=$sep
	
	# system
	PS1+="${lb}\[$(tput setaf ${PROMPT_DUBKAT['MISCCOLOR']})\]"
	PS1+="${DISTRO_COLOR}${PRETTY_NAME}\[$(tput sgr0)\]"
	#PS1+="/"
	#if [ $(yesno ${PROMPT_DUBKAT['SWAP_KERNEL_VERSION_TO_PRODUCT']}) ] && [ "${OS_KERN}" = "Linux" ]; then
	#		PS1+="${DISTRO_COLOR}${OS_RELEASE_VERSION}\[$(tput sgr0)\]"
	#else
	#	PS1+="${OS_KVER}"
	#fi
	PS1+="\[$(tput sgr0)\]${rb}"
	PS1+=$sep

	
	# The date string
	#PS1+="${lb}\[$(tput setaf ${PROMPT_DUBKAT['DATECOLOR']})\]\D{%A %B %d, %Y %H:%M:%S} ${TZ#*/}${rb}"
	PS1+="${lb}$(pretty_date)${rb}"
	PS1+=$sep

	PS1+="${lb}up: $(duptime)${rb}${sep}"
	
	#PS1+="${lb}load: $(loadcheck)${rb}${sep}"


	split=
	if [ `echo ${#PS1} / 2 | bc` -ge ${COLUMNS} ]; then
		#echo "DEBUG: PS1(${#PS1}) COLUMNS(${COLUMNS})"
		PS1+="\n"
	else
		split="\n"
	fi

	# return code display
	PS1+="${lb}$(r_code)${rb}"
	PS1+=$sep

	# the current working directory display
	PS1+="${lb}\[$(tput setaf ${PROMPT_DUBKAT['PATHCOLOR']})\]\w${rb}"
	PS1+=$sep
	
	DUBKAT_PROMPT['ICON']="${DUBKAT_PROMPT['ICON']:-➟}"

	# Finely the prompt symbol
	PS1+="${split}\[$(tput setaf ${PROMPT_DUBKAT['MISCCOLOR']})\]${DUBKAT_PROMPT['ICON']}\[$(tput sgr0)\] "

	export PS1
	unset sep split lb rb S P DCOLOR userhost

}

declare -A PROMPT_DUBKAT

export PROMPT_COMMAND="${PROMPT_COMMAND:-dprompt}"

	
	## The following are booleans (true/false) settings.
	## Valid options are true, false, on, off, yes, no, enabled, disabled, 0, 1

	# do we autoclear the screen ?
	PROMPT_DUBKAT['AUTOCLEAR']="${PROMPT_DUBKAT['AUTOCLEAR']:-no}"

	# include the system name / version
	PROMPT_DUBKAT['SHOWUNAME']="${PROMPT_DUBKAT['SHOWUNAME']:-yes}"

	# show the return code of the last command?
	PROMPT_DUBKAT['SHOWRETURN']="${PROMPT_DUBKAT['SHOWRETURN']:-yes}"

	# show our current directory path
	PROMPT_DUBKAT['SHOWPATH']="${PROMPT_DUBKAT['SHOWPATH']:-yes}"

	## the following are strings
	# show a long, formated date. see strftime or man date
	dmt="%A %B %d, %Y %H:%M:%S"
	PROMPT_DUBKAT['DATEFORMAT']="${PROMPT_DUBKAT['DATEFORMAT']:-${dmt}}"
	unset dmt

	# show our terminal name?
	PROMPT_DUBKAT['SHOWTERM']="${PROMPT_DUBKAT['SHOWTERM']:-yes}"
	# this variable wont change between sessions, so dont keep setting it.
	if [ "x${PROMPT_DUBKAT['TERMLONG']}" = "x" ]; then
		PROMPT_DUBKAT['TERMLONG']="␋ $(tput longname)"
	fi

	# what color for the username part. see the output from colortest.sh
	PROMPT_DUBKAT['MISCCOLOR']=${PROMPT_DUBKAT['MISCCOLOR']:-87}
	PROMPT_DUBKAT['USERCOLOR']=${PROMPT_DUBKAT['USERCOLOR']:-51}
	PROMPT_DUBKAT['HOSTCOLOR']=${PROMPT_DUBKAT['HOSTCOLOR']:-48}
	#PROMPT_DUBKAT['DATECOLOR']=${PROMPT_DUBKAT['DATECOLOR']:-${PROMPT_DUBKAT['MISCCOLOR']}}
	PROMPT_DUBKAT['PATHCOLOR']=${PROMPT_DUBKAT['PATHCOLOR']:-240}
	PROMPT_DUBKAT['BRACKETCOLOR']=${PROMPT_DUBKAT['BRACKETCOLOR']:-33}
	PROMPT_DUBKAT['SEPERATOR']=${PROMPT_DUBKAT['SEPERATOR']:-·}
	PROMPT_DUBKAT['SEPCOLOR']=${PROMPT_DUBKAT['SEPCOLOR']:-51}
	PROMPT_DUBKAT['LB']=${PROMPT_DUBKAT['LB']:=\{}
	PROMPT_DUBKAT['RB']=${PROMPT_DUBKAT['RB']:=\}}
