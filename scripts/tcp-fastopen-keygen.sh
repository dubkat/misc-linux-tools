#!/bin/sh
# Enable TCP FastOpen.
# Stolen, almost verbatim from https://bradleyf.id.au/nix/shaving-your-rtt-wth-tfo/

if [ $UID -gt 0 ]; then
    echo "Must be root."
    exit 1
fi

echo 'net.ipv4.tcp_fastopen=3' > /etc/sysctl.d/50-tcp_fastopen.conf

RAND=$(openssl rand -hex 16)
NEWKEY=${RAND:0:8}-${RAND:8:8}-${RAND:16:8}-${RAND:24:8}
echo "net.ipv4.tcp_fastopen_key=$NEWKEY" > /etc/sysctl.d/50-tcp_fastopen_key.conf
chmod 600 /etc/sysctl.d/50-tcp_fastopen_key.conf; 
chown root /etc/sysctl.d/50-tcp_fastopen_key.conf
unset RAND NEWKEY

sysctl -p /etc/sysctl.d/50-tcp_fastopen.conf
sysctl -p /etc/sysctl.d/50-tcp_fastopen_key.conf


