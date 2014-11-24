#!/bin/bash
# 2014-09-14
# $Id$

# Black       0;30     Dark Gray     1;30
# Blue        0;34     Light Blue    1;34
# Green       0;32     Light Green   1;32
# Cyan        0;36     Light Cyan    1;36
# Red         0;31     Light Red     1;31
# Purple      0;35     Light Purple  1;35
# Brown       0;33     Yellow        1;33
# Light Gray  0;37     White         1;37



export HOSTFILE="/etc/HOSTNAME"
export MAN_POSIXLY_CORRECT=1
export RXVT_SOCKET="/tmp/rxvt-socket-${USER}.socket"

alias ccze="ccze -A"
alias ls="ls --group-directories-first --color=auto"
alias diff="colordiff"


function _unalias ()
{
    alias $1 2>/dev/null 1>/dev/null && unalias $1 || true
}

_unalias ll
function ll ()
{
        ls -hlvB --classify --dereference --color=force $@
}

_unalias la
function la ()
{
	ll --almost-all $@
}

_unalias dir
function dir ()
{
	dir -hlvB --classify --color=auto --almost-all --group-directories-first --dereference --author $@
}

_unalias mtr
function mtr ()
{
	/usr/sbin/mtr --report --report-wide $@ | ccze
}

_unalias ipt
function ipt ()
{
	/usr/sbin/iptables $@ | ccze
}

_unalias df
function df ()
{

	/usr/bin/df $@ 2>/dev/null | ccze
}


_unalias userlist
function userlist ()
{
    [ "$EUID" == 0 ] || return 255

	local userlist="$(mktemp /dev/shm/userlist.XXXXX)"
	echo "UID:GID:USERNAME:SHELL:HOME:GECOS" > ${userlist}
	echo "---:---:--------:-----:----:-----" >> ${userlist}
	cat /etc/passwd | awk -F: '{ printf "%d:%d:%s:%s:%s:%s\n", $3, $4, $1, $7, $6, $5 }' | sort -h >> ${userlist}
	column -ts: ${userlist}
	rm ${userlist}
}


function _homesize ()
{
    echo -n `du -hs $1 | awk '{ print $1 }'`
}

_unalias luserlist
function luserlist ()
{
    [ "$EUID" == 0 ] || return 255

    function _homesize ()
    {
        echo -n `du -hs $1 | awk '{ print $1 }'`
    }


    local passlist="$(mktemp /dev/shm/passlist.XXXXX)"
    local userlist="$(mktemp /dev/shm/userlist.XXXXX)"
    local uidmin="`grep -P '^UID_MIN' /etc/login.defs | awk '{ print $2 }'`"
    local uidmax="`grep -P '^UID_MAX' /etc/login.defs | awk '{ print $2 }'`"

    # echo "userlist = $userlist"
    # echo "passlist = $passlist"
    # echo "uidmin = $uidmin"
    # echo "uidmax = $uidmax"


    echo "UID:GID:USERNAME:SHELL:HOME:SPACE_USED" > ${userlist}
    echo "---:---:--------:-----:----:----------" >> ${userlist}
    cat /etc/passwd | awk -F: '{ printf "%d:%d:%s:%s:%s:%%homesize%%\n", $3, $4, $1, $7, $6 }' | sort -h > ${passlist}

    # here's my nifty multi-line perl one-liner :)
    # print out usernames starting from the system min to system max user ids
    perl -F: -i -lane  '{ BEGIN { $low = shift; $high = shift;  }; print $_ if ( $F[0] >= $low && $F[0] <= $high ); }' $uidmin $uidmax ${passlist}

    for x in  $(awk -F: '{ print $5 }' ${passlist}); do
        size=$(_homesize $x);
        sed -i -e 's/:$x:%homesize%/:$x:$size/' ${passlist}
    done

     cat ${passlist} >> ${userlist}
     rm ${passlist}
     cat ${userlist} | column -ts:
     rm ${userlist}

}

_unalias usermod_auto_nologin
function usermod_auto_nologin ()
{
	[ "$EUID" == 0 ] || return 255
	local users="`grep /bin/false /etc/passwd | cut -d: -f1`"
	echo  "Changing shells from /bin/false to /usr/sbin/nologin for the following users:"
	for x in $users; do
		echo -n "* ${x}		"
		usermod -s /usr/sbin/nologin $x 
		if [ "$?" == 0 ]; then
			echo "Ok."
		else
			echo "Failed."
		fi
	done
	echo "Done."
}


alias equalizer="/usr/bin/qpaeq"

function ssh-keygen-auto ()
{
    unset password;
    unset name;
    unset expscr;
    # thank you stack exchange!
    echo -n "Enter remote hostname: "
    read name;

     [[ -z $name ]] && return 255;

    # do some work while the humans brain catches up
    expscr="$(mktemp /dev/shm/keygen-auto-${name}-XXXXXX)"
    file="${HOME}/.ssh/${name}"

    echo -n "Enter a password: "
    while IFS= read -r -s -n1 pass; do
      if [[ -z $pass ]]; then
           echo
           break
      else
           echo -n '*'
           password+=$pass
      fi
    done
    echo "file: $file"
    echo "password: $password"
    cat<<EOF >$expscr
#!/usr/bin/expect
global argv
set debug 0
set pos 0
set type none
set bits 4096

if { \$debug == 1 } { 
    send_user "\$argv0 [lrange \$argv 0 2]\n"
}

if { \$argc != 1 } { 
    send_user "\n***\n* ERROR\n*\n* Script should be called as \$argv0 (ecdsa|rsa)\n*\n*\n*"
    exit 1
}

set type "[lindex \$argv \$pos]"
if { \$type == "--" } {
    incr pos
    set type "[lindex \$argv \$pos]"
}

set type "[string tolower \$type]"

if { ![string match ecdsa \$type] && ![string match rsa \$type] } {
    puts "You fool,  ECDSA or  RSA\n"
    exit 1
} else {
    if { \$debug == 1 } {
        puts "Match: type = \$type"
   }
}

if { [string match ecdsa \$type] } {
    set bits 521
}

spawn /usr/bin/ssh-keygen -t \$type -b \$bits
# variables before were processed by TCL
# variables after were processed by bash, and thus
# the variables have been filled in prior to
# this script being run.

expect "save the key"
send "$file.\$type\n"

#expect "$file.\$type already exists"
#send "no\n"
#send_user "\n***\n* ERROR\n*\n* I wont overwrite keys that pre-exist.\n* You may want to remove, or rename $file.\$type\n* Or you can try with a different name\n* Then, try running this script again.\n*\n*\n*"

expect "Enter passphrase"
send "$password\n"

expect "Enter same passphrase again"
send "$password\n"

interact

EOF
    chmod 700 $expscr
    /usr/bin/expect -f ${expscr} ecdsa
    [ "$?" != "0" ] && return $? ||  true
    /usr/bin/expect -f ${expscr} rsa
    [ "$?" != "0" ] && return  255 || true


    cat ${file}.rsa ${file}.ecdsa > ${file}.keys.pem
    cat ${file}.rsa.pub ${file}.ecdsa > ${file}.keys.pub
    echo "The following files were created."
    echo "* ECDSA"
    echo "  * ${file}.ecdsa"
    echo "  * ${file}.ecdsa.pub"
    echo "* RSA"
    echo "  * ${file}.rsa"
    echo "  * ${file}.rsa.pub"

    return 0;
}



#export NETWORK_PUBLIC_V4="`curl -s -4 ip.appspot.com`"
#export NETWORK_PUBLIC_v6="`curl -s -6 ip.appspot.com`"

if [ "$SHLVL" != "1" ]; then
    /usr/local/bin/syshead.sh
fi

