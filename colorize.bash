# colorized output of select commands
# Sparkles & Poniez for all.

if ! hash colout 2>/dev/null; then return; fi

# console mediainfo
if [ "x${COLORIZE}" = "xyes" ]; then

	function df {
		fsrx='(/[^ ]*)|(fuseblk)|(fuse.sshfs|sshfs)|(hfs)|(msdos)|(exfat)|(autofs)|(devtmpfs|procfs|devfs|tmpfs)|(reiserfs\d?)|(ext4)|(ext3)|(ext2)|(btrfs)|(xfs)|(ufs|iso8859)'
		fsco='white,cyan,green,green,black,yellow,white,black,black,green,yellow,red,yellow,green,cyan'
		command df $* | colout "$fsrx" "$fsco" | colout ' \b[\d.]*[KMGT0]\b ' cyan Spectrum | colout --scale 0,100 '\s*[0-9]{1,3}%\s*' Scale;
	}

	function ps {
		command ps $* | colout '(USER|PID|%CPU|%MEM|VSZ|RSS|TT|STAT|STARTED|TIME|COMMAND)' white, underline | colout '^.*$' Random
	}

	function mount {
		command mount $* | colout '^(\S+) on (\S+) type (\S+) \((.*)\)$' green,cyan,blue,magenta bold
	}

	function lsof {
		command lsof $* | colout -a '(COMMAND|PID|DEVICE|USER|FD|TYPE|SIZE/OFF|NODE|NAME)|\b(\d+)\b|(IPv[64])|(TCP)|(UDP)|(\S+):([^ ]+)|(->)|([^ ]+)' white,red,cyan,yellow,blue,cyan,magenta,red,white underline,bold
	}
	function printenv {
		command printenv $* | sort | colout '([^=]*)=(.*)' Spectrum,white italic,
	}

	if hash mediainfo 2>/dev/null; then
		function mediainfo {
			command mediainfo "$@" | colout  "([^:]+):(.*)" Spectrum,Spectrum italic,normal
		}
	fi

	for x in md5{sum,deep,hmac} shasum sha1{sum,deep,hmac} sha224{sum,deep,hmac} sha256{sum,deep,hmac} sha384{sum,deep,hmac} sha512{sum,deep,hmac} whirlpooldeep tigerdeep; do
		hash_regex='^(?:(.+): (OK)|(.+): (FAILED))'
		hash_colors="black,green,white,red"

		if hash $x 2>/dev/null; then
			case $x in
				md5sum   ) function md5sum 	{ command md5sum $*  	| colout "$hash_regex" "$hash_colors"; } ;;
				shasum   ) function shasum  	{ command shasum $*  	| colout "$hash_regex" "$hash_colors"; } ;;
				sha1sum  ) function sha1sum 	{ command sha1sum $* 	| colout "$hash_regex" "$hash_colors"; } ;;
				sha1hmac ) function sha1hmac 	{ command sha1hmac $* 	| colout "$hash_regex" "$hash_colors"; } ;;
				sha224sum ) function sha224sum 	{ command sha224sum $* 	| colout "$hash_regex" "$hash_colors"; } ;;
				sha256sum ) function sha256sum	{ command sha256sum $*	| colout "$hash_regex" "$hash_colors"; } ;;
				sha256hmac ) function sha256hmac { command sha256hmac $*	| colout "$hash_regex" "$hash_colors"; } ;;
				sha384sum ) function sha384sum	{ command sha384sum $*	| colout "$hash_regex" "$hash_colors"; } ;;
				sha384hmac ) function sha384hmac { command sha384hmac $*	| colout "$hash_regex" "$hash_colors"; } ;;
				sha512sum ) function sha512sum	{ command sha512sum $*	| colout "$hash_regex" "$hash_colors"; } ;;
				sha512hmac ) function sha512hmac { command sha512hmac $*	| colout "$hash_regex" "$hash_colors"; } ;;
							
				* ) echo "Warning: missing color definition for $x in colorize" >&2 ;;
			esac
		fi
	done
	
	ipt_regex='(ACCEPT)|(REJECT)|(DROP)|(LOG)|(udp)|(tcp)|(icmp\S*)|(dpts?)|(multicast|broadcast)'
	ipt_colors='118,203,197,159,207,183,199,150,100'
	ipt_extras=''

	if hash iptables 2>/dev/null; then
		function iptables {
			command iptables "$@" | colout "$ipt_regex" "$ipt_colors" "$ipt_extras"
		}
		function ip6tables {
			command ip6tables "$@" | colout "$ipt_regex" "$ipt_colors" "$ipt_extras"
		}
	fi




fi
