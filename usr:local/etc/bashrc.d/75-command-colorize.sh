# colorized output of select commands
# Sparkles & Poniez for all.
# Dan Reidy <dubkat@gmail.com>
# https://github.com/dubkat
ULE_VERSION['colorize']=16.08.16
export ULE_RUNTIME=75

if ! hash colout 2>/dev/null; then return; fi

if [ -z "$COLORIZE" ]; then return; fi

if [ "x${COLORIZE}" != "xyes" ]; then return; fi

# a few things do it for us with no work.
if hash colordiff 2>/dev/null; then
	alias diff="`command -v colordiff`"
fi

if hash colorsvn 2>/dev/null; then
	alias svn="`command -v colorsvn`"
fi

if hash hostnamectl 2>/dev/null; then
	hostnamectl() {
		if [ ${#@} -gt 0 ]; then
			command hostnamectl $@
			return $?
		fi
		command hostnamectl | colout '^([^:]+): (.*)$' white,Hash
	}
fi

if hash wshaper.htb 2>/dev/null; then
	function qos {
		wshaper.htb "$*" | \
		colout '(qdisc (?:\S+) \d+)|(root)|(parent (?:\d+:\d+))|(limit \d+)|(quantum \d+)|(class \S+ \d+:\d+)|(prio \d+)|(rate (?:\S+))|(ceil \S+)|(\bburst \S+)|(cburst \S+)|(lended: \d+)|(borrowed: \d+)|(giants: \d+)|(\btokens: \d+)|(ctokens: \d+)' Hash
	}
fi

if hash nmap 2>/dev/null; then
	function _nmap_netscout {
		: ${1?required argument: network block, such as 192.168.1.0/24}
		sudo nmap -sn --open "$@" | colout 'scan report for ([^ ]+)|\(([^\)]+)\)|([A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2}:[A-F0-9]{2})|Host is (up)|(Unknown)' \
		Hash,white,153,182,196 bold,normal,normal,normal,normal
	}
        alias nmap.netscout="_nmap_netscout"
fi

if hash socklist 2>/dev/null; then
	function _socklist {
		command socklist | \
		colout -d Spectrum --scale 0,65535 \
		'^(?:(type.*))$|^(?:(tcp)|(udp)|(tcp6)|(udp6))\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+(.*)$' \
		white,162,172,165,184,Scale,red,Hash,hash,hash,111 \
		reverse,normal,normal,bold,bold,Spectrum,bold,bold,bold,bold,italic
	}
	alias socklist="_socklist"
fi

if hash zypper 2>/dev/null; then
	function _repo_list {
		local arg="${1:- -pa}"
		sudo zypper --table-style ${ZYPPER_TABLE_STYLE:-2} lr $arg | colout -d Spectrum --scale 0,100 \
		'(^#.*$)|([─│┼])|((?:base|alpha|repo|devel|home|obs|[xyz]|google|fact(?:ory)?)-[^ ]+)|(\bYes\b)|(\bNo\b)|(^\s*\d*)|(\d\d*\s*$)' \
		white,purple,Hash,green,red,Spectrum,Scale \
		reverse,normal,Spectrum,bold,bold,Spectrum,Scale
	}

	alias repo-list="_repo_list"
fi


function df {
	local fsrx='(/[^ ]*)'
	loca fs=" (fuseblk|fuse.sshfs|sshfs|hfs|msdos|exfat|autofs|devtmpfs|procfs|devfs|tmpfs|reiserfs\d?|ext[234]|btrfs|xfs|ufs|iso8859) "
	local fsco='Hash'
	command df $* | colout "$fsrx" white | colout "$fs" Hash Hash | colout ' \b[\d.]*[KMGT0]\b ' cyan rainbow | colout --scale 0,100 '\s*([0-9]{1,3}%)\s*' scale;
}

if hash di 2>/dev/null; then
	function di {
		local opts=" -ssm -dh "
		local otypes="iso8859,udf,devtmpfs,sysfs,securityfs,proc,mqueue,devpts,debugfs,hugetlbfs,pstore,rpc_pipefs,cgroup,binfmt_misc"
		local types="ext4,ext3,ext2,btrfs,xfs,reiserfs,ntfs,vfat,exfat,hfs,fuse.sshfs,fuse.unionfs,nfs"
		local DI_ARGS="${DI_ARGS} ${opts}"
		if [ ${#@} -gt 0 ]; then
			if [ "$1" = "full" ]; then
				DI_ARGS+=" --all"
				shift
			elif [ "$1" = "short" ]; then
				DI_ARGS+=" -I$(awk '/^[[:space:]]+[[:alpha:]]+/ { print $NF }' /proc/filesystems | tr '\n' ',')"
				shift
			fi

		else
			DI_ARGS+=" -I${types} -srs"
		fi
		command di ${DI_ARGS} $@ | \
		colout --scale 0,100 \
		'^([^ ]+)\s+(/?[^ ]*)\s+([0-9\.]+[GMTK]?)\s+([0-9\.]+[GMTK]?)\s+([0-9\.]+[GMTK]?)\s+(\d+%)\s+([^ ]+)(?:\s+([^ ]+)?)' \
		Hash,201,yellow,red,green,scale,Hash,white \
		Hash,bold,normal,normal,normal,bold,Hash,italic | \
		\
		colout '^(Filesystem.*|[ ]*Total[ ].*)' \
		222 \
		reverse
	}
fi


#function ps {
#command ps $* | colout '(USER|PID|%CPU|%MEM|VSZ|RSS|TT|STAT|STARTED|TIME|COMMAND)' white, underline | colout '^.*$' Random
#	command ps $* | colout '^([ ^]+) .*' Hash Hash
#}

function mount {
	command mount $* | colout '^(\S+) on (\S+) type (\S+) \((.*)\)$' green,cyan,blue,magenta bold
}

#error prone on gentoo
#function lsof {
#	command lsof $* | colout -a '(COMMAND|PID|DEVICE|USER|FD|TYPE|SIZE/OFF|NODE|NAME)|\b(\d+)\b|(IPv[64])|(TCP)|(UDP)|(\S+):([^ ]+)|(->)|([^ ]+)' \
#	white,red,cyan,yellow,blue,cyan,magenta,red,white underline,bold
#}
function printenv {
	command printenv $* | sort | colout -a '([^=]*)(=)(.*)' 199,255,214 normal,bold,normal
}

if hash mediainfo 2>/dev/null; then
	function mediainfo {
		command mediainfo "$@" | colout  "(.*)\s\s+:(.*)" white,199 bold,bold | colout '^(General|Video|Audio|Menu|Text).*' magenta reverse
	}
fi

for x in md5{sum,deep,hmac} shasum sha1{sum,deep,hmac} sha224{sum,deep,hmac} sha256{sum,deep,hmac} sha384{sum,deep,hmac} sha512{sum,deep,hmac} whirlpool{deep,sum} tigerdeep; do
	hash_regex='^(?:(.+): (OK)|(.+): (FAILED))'
	hash_colors="black,green,white,red"

	if hash $x 2>/dev/null; then
		case $x in
			md5sum   ) function md5sum 	 { command md5sum $*  	| colout "$hash_regex" "$hash_colors"; } ;;
			shasum   ) function shasum  	 { command shasum $*  	| colout "$hash_regex" "$hash_colors"; } ;;
			sha1sum  ) function sha1sum 	 { command sha1sum $* 	| colout "$hash_regex" "$hash_colors"; } ;;
			sha1hmac ) function sha1hmac 	 { command sha1hmac $* 	| colout "$hash_regex" "$hash_colors"; } ;;
			sha224sum ) function sha224sum 	 { command sha224sum $* | colout "$hash_regex" "$hash_colors"; } ;;
			sha256sum ) function sha256sum	 { command sha256sum $*	| colout "$hash_regex" "$hash_colors"; } ;;
			sha256hmac ) function sha256hmac { command sha256hmac $*| colout "$hash_regex" "$hash_colors"; } ;;
			sha384sum ) function sha384sum	 { command sha384sum $*	| colout "$hash_regex" "$hash_colors"; } ;;
			sha384hmac ) function sha384hmac { command sha384hmac $*| colout "$hash_regex" "$hash_colors"; } ;;
			sha512sum ) function sha512sum	 { command sha512sum $*	| colout "$hash_regex" "$hash_colors"; } ;;
			sha512hmac ) function sha512hmac { command sha512hmac $*| colout "$hash_regex" "$hash_colors"; } ;;
			whirlpoolsum ) function whirlpoolsum { command whirlpoolsum $*|colout "$hash_regex" "$hash_colors"; } ;;
			whirlpooldeep ) function whirlpooldeep { command whirlpooldeep $* | colout "$hash_regex" "$hash_colors"; } ;;
			tigerdeep ) function tigerdeep { command tigerdeep $* | colout "$hash_regex" "$hash_colors"; } ;;

		esac
	fi
	unset x hash_colors hash_regex
done

if hash iptables 2>/dev/null; then
	function iptables {
		local ipt_rx_table="^\s*(?:pkts|bytes|target|prot|opt|in|out|source|destination).*\n"; local ipt_co_table="white"
		local ipt_rx_chain="[Cc]hain ([^ ]+)"; local ipt_co_chain=124
		local ipt_rx_ref="([0-9]+) references"; local ipt_co_ref=197
		local ipt_rx_ip="\s([0-9\.:ABCDEFabcdef]+/[0-9]{1,3})\s"; local ipt_co_ip="magenta";
		local ipt_rx_bad="(DROP|TARPIT|INVALID)"
		local ipt_rx_meh="(REJECT|CHAOS|anywhere|0.0.0.0\/0)"
		local ipt_rx_ok="(ACCEPT|LOG)"
		local ipt_rx_return="\s*(RETURN)\s*"; local ipt_co_return="green"
		local ipt_rx_port=":(\d+(:?:\d+))"
		local ipt_co_bad=197
		local ipt_co_meh=203
		local ipt_co_ok=118
		local ipt_co_port=200
		command iptables "$@" | colout "${ipt_rx_chain}" "${ipt_co_chain}" bold |
		colout "${ipt_rx_table}" "${ipt_co_table}" reverse |
		colout "${ipt_rx_ref}" "${ipt_co_ref}" normal |
		colout "${ipt_rx_return}" "${ipt_co_return}" normal |
		colout "${ipt_rx_ip}" "${ipt_co_ip}" bold |
		colout "${ipt_rx_bad}" "${ipt_co_bad}" bold |
		colout "${ipt_rx_meh}" "${ipt_co_meh}" bold |
		colout "${ipt_rx_ok}" "${ipt_co_ok}" |
		colout "${ipt_rx_port}" "${ipt_co_port}"
	}

	function ip6tables {
		command ip6tables "$@" | colout "$ipt_regex" "$ipt_colors" "$ipt_extras"
	}

fi
