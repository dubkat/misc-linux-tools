#!/bin/bash
# stratum.sh - View a report of NTP servers used for several known Linux distributions.
# Copyleft (C) 2013 Dan Reidy <dubkat@gmail.com>
# Artistic License - give credit where credit is due.
# $Id$

echo
echo "This is going to take a while based on the speed of your DNS servers, "
echo "   remote WHOIS servers, and remote NTP servers."
echo

distros="opensuse gentoo fedora redhat centos novell debian ubuntu"
countries="us ca mx ie uk nl no se de ru es ch"

echo "Checking IPs in NTP Pool for distros."

for dist in $distros; do 
	printf "*    %10s " $dist
	#echo -n "Checking IPs in NTP Pool for $dist "

	for x in `seq 0 3 | sort -r`; do 		
		dig +short @8.8.8.8              A    ${x}.${dist}.pool.ntp.org >> /tmp/.stratum4.$$;
		dig +short @2001:4860:4860::8888 AAAA ${x}.${dist}.pool.ntp.org >> /tmp/.stratum6.$$;
		echo -n "$x "

	done
	echo
done

echo "Checking for IPs in country-based DNS pools..."

for country in $countries; do
	echo -n "*    $country: "
	for x in `seq 0 3 | sort -r`; do
		dig +short @8.8.8.8              A    ${x}.${country}.pool.ntp.org >> /tmp/.stratum4.$$;
		dig +short @2001:4860:4860::8888 AAAA ${x}.${country}.pool.ntp.org >> /tmp/.stratum6.$$;
		echo -n "$x "
	done
	echo
done

echo "Checking for IPs in generic DNS pool..."
echo -n "*    Pool: "
for x in `seq 0 3 | sort -r`; do
	echo -n "$x.pool.ntp.org "
	dig +short @8.8.8.8              A    ${x}.pool.ntp.org >> /tmp/.stratum4.$$;
	dig +short @2001:4860:4860::8888 AAAA ${x}.pool.ntp.org >> /tmp/.stratum6.$$;
done
dig +short @8.8.8.8              A    pool.ntp.org >> /tmp/.stratum4.$$;
dig +short @2001:4860:4860::8888 AAAA pool.ntp.org >> /tmp/.stratum6.$$;
echo " Done.	"


test -f /tmp/.stratum4.$$ && cat /tmp/.stratum4.$$ | sort -h | uniq > /tmp/stratum4.$$;
test -f /tmp/.stratum6.$$ && cat /tmp/.stratum6.$$ | sort -h | uniq > /tmp/stratum6.$$;

count4=$(cat /tmp/stratum4.$$ | wc -l);
count6=$(cat /tmp/stratum6.$$ | wc -l);
total=$(echo ${count4}+${count6} | bc);

echo "This next step is going to take a while."
echo "Go get a Starbucks."
echo
echo -n "Looking up the NETOWNER and STRATUM of $total total servers found..."

echo "IP Stratum Country Hostname AS Network_IDs Network_Name" > /tmp/.timeservers.$$;

for file in $(ls /tmp/*.$$); do
	for ip in $(<$file); do
		istrat=$(ntpdate -q ${ip} 2>/dev/null | cut -s -d "," -f 2 | awk '{ print $2 }' );
		netname=$(whois ${ip} 2>/dev/null | grep -i ^netname: | awk '{ print $2 }' | tr '\n' '/' );
		country=$(geoiplookup ${ip} |head -n1| cut -s -d: -f2 | cut -d, -f2 | sed 's#^ ##' );
		co=$(geoiplookup ${ip} | head -n1| cut -s -d: -f2 | cut -d, -f1 | sed 's#^ ##');
		asnum=$(geoiplookup ${ip} |tail -n1 | awk -F: '{ print $2 }' | cut -d" " -f2 );
		netid=$(geoiplookup ${ip} | tail -n1 | awk -F: '{ print $2 }' | sed -e 's#^ ##' | cut -d" " -f1 --complement );
		hostname=$(dig +short -x $ip)


		printf "%-16s %s %s %s %s %s \n" $ip $istrat $co $hostname $asnum $netid $netname >> /tmp/.timeservers.$$ 

		# UNSET	
		unset istrat
		unset netname
		unset country
		unset co
		unset asnum
		unset netid
		unset hostname
	done
done

echo " Done."

# do a tiny little formatting fix. Chop off any trailing '/'
sed -i /tmp/.timeservers.$$ -e 's#/$##' -e 's#/# / #g'
cat /tmp/.timeservers.$$ | column -t > /tmp/timeservers-`date -I`.txt

echo
echo "Charting distribution Network Time Servers complete."
echo "I found $count4 IPv4 Time Servers"
echo "I found $count6 IPv6 Time Servers"
echo "You can view the list servers in the file /tmp/timeservers-`date -I`.txt"
echo

rm /tmp/.timeservers.$$ /tmp/stratum4.$$ /tmp/stratum6.$$;


exit 0;


