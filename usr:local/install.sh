#!/bin/sh
# simple script installer
# (C) 2016 Dan Reidy <dubkat@gmail.com>

prefix="${prefix:-/usr/local}"
env_prefix="${prefix}/etc"
bin_prefix="${prefix}/bin"
sbin_prefix="${prefix}/sbin"
owner=root
group=root

yel=;
gre=;
red=;
blu=;
pur=;
bld=;
rst=;

if hash tput 2>/dev/null; then
        bld=$(tput bold);
        rst=$(tput sgr0);

        case $(tput colors) in
                256 )
                        yel=$(tput setaf 178);
                        gre=$(tput setaf  82);
                        red=$(tput setaf 203);
                        blu=$(tput setaf  86);
                        pur=$(tput setaf 140);
                ;;
        esac
fi


#if [ ! -z "$1" ]; then
#        if [ "$1" = "local-install" ]; then
#                bin_dir="~/bin"
#                env_dir="~/.local/share/ule-scripts"
#                owner="$(id -u -n)"
#                group="$(id -g -n)"
#        elif [ "$1" = "custom-prefix" ]; then
#                prefix="${2?you must include a prefix directory}"
#                bin_dir="${prefix}/bin"
#                env_dir="${prefix}/etc"
#        fi
#else
        if [ $UID -gt 0 ]; then
                echo "${red}You must be root to install globally.${rst}"
                #echo "If you want a local user copy, run this script again like so..."
                #echo "$0 local-install"
                exit 1
        fi
#fi

i=0
MISSING="";
BINS="figlet toilet finger whois geoiplookup curl colout"
echo -n "Testing for required binaries... ${blu}"
for x in $BINS; do
        echo -n "$x "
        if ! hash $x 2>/dev/null; then
                i=$[i + 1]
                MISSING+="$x "
        fi
done
echo "${rst}"

if [ $i -gt 0 ]; then
        echo "Please install the ${red}${i}${rst} missing packages: ${blu}${MISSING}${rst}"
        exit $i
fi

echo "Installing to $(realpath ${prefix})"

mkdir -p -m 750 ${sbin_prefix} 2>/dev/null; chown root:wheel ${sbin_prefix} 2>/dev/null;
mkdir -p -m 755 ${bin_prefix} 2>/dev/null;  #chmod 755 ${bin_prefix} 2>/dev/null
mkdir -p -m 755 ${env_prefix}/bashrc.d 2>/dev/null; chmod 755 ${env_prefix}/bashrc.d 2>/dev/null

ind=$[${#env_prefix}];
echo "${bld}${blu}$env_prefix/${rst}"
for x in etc/*; do
        [ -d $x ] && continue;
        printf "%${ind}s ${yel}%s${rst} \n" " " $(basename $x)
        install -o root -g root -m644 $x ${env_prefix}
done
for x in fruitpunch.colors zenburn.colors; do
    if [ -r ../$x ]; then
    printf "%${ind}s ${yel}%s${rst} \n" " " $(basename ../$x);
    install -o root -g root -m644 ../$x ${env_prefix};
done


ind=$[ind + 8];
echo "${bld}${blu}$env_prefix/bashrc.d/${rst}"
for x in etc/bashrc.d/*; do
        printf "%${ind}s ${gre}%s${rst}\n" " " $(basename $x)
        install -o root -g root -m644 $x ${env_prefix}/bashrc.d
done

ind=$[${#bin_prefix}];
echo "${bld}${blu}$bin_prefix/${rst}"
for x in bin/*; do
        printf "%${ind}s ${pur}%s${rst}\n" " " $(basename $x)
        install -o root -g root -m 755 ${x} ${bin_prefix}
done

ind=$[${#sbin_prefix}];
echo "${bld}${blu}$sbin_prefix/${rst}"
for x in sbin/*; do
        printf "%${ind}s ${red}%s${rst}\n" " " $(basename $x)
        install -o root -g wheel -m 750 ${x} ${sbin_prefix}
done


sed -i \
    -e "s@%env_prefix%@${env_prefix}@g"   \
    -e "s@%bin_prefix%@${bin_prefix}@g"   \
    -e "s@%sbin_prefix%@${sbin_prefix}@g" \
    ${env_prefix}/bashrc


echo
echo "* Install Complete."
echo "* Dont forget to add '${yel}test -r ${env_prefix}/bashrc && source ${env_prefix}/bashrc${rst}' to /etc/bashrc.local"
echo "* or your system's equivelent. You could also add it to your ~/.bashrc"
echo
echo "${bld}Script Locations:${rst}"
echo "* ${bld}Root / Wheel / Admin${rst}: ${red}$sbin_prefix${rst}"
echo "* ${bld}General User Scripts${rst}: ${pur}$bin_prefix${rst}"
echo "* ${bld}Environment & Functions${rst}: ${yel}$env_prefix${rst}"
echo
echo "* After running '${yel}source $env_prefix/bashrc${rst}' you can test outcome via..."
echo "${yel}ule_version${rst}"
echo "${pur}$bin_prefix/system-welcome.sh${rst}"
echo "${red}$sbin_prefix/free-disk-cache.sh${rst}"
echo
