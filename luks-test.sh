#!/bin/bash
# test system cryptsetup for supported encryption types
# Copyright (C) 2016 Dan Reidy <dubkat@gmail.com>

if ! hash cryptsetup 2>/dev/null; then
  # just in case sbin isn't in the path...
  if [ -x /usr/sbin/cryptsetup ]; then
    hash -p cryptsetup /usr/sbin/cryptsetup
  elif [ -x /sbin/cryptsetup ]; then
    hash -p cryptsetup /sbin/cryptsetup
  else
    echo "no luks, no ducks." >/dev/stderr;
    exit 1;
  fi
fi

function crypt_backend() {
  for backend in $(ldd $(hash -t cryptsetup) | egrep '(gcrypt|libssl|libcrypto)' | awk '{ print $3 }'); do
    rpm -qf $backend --queryformat "%{N}/%{V} ";
  done
}


function record_result() {
  local value=$1
  local result="unknown"
  case $value in
    0 )
    result="true";
    let good=$[good + 1];
    ;;
    * )
    result="false";
    ;;
  esac
  echo "${cipher},${mode},${tweak},${hash},${size},${testname},${result}" >> $csv;
}

function run_crypt() {
  local cipher=$1
  local mode=$2
  tweak=$3
  local hash=$4
  local size=$5
  #local skew=

  if [ $tweak = "essiv" ]; then
    for skew in $hashes; do
      let total=$[int + 1];
      tweak="essiv:${skew}"
      cryptsetup -q luksFormat -i 500 -c ${cipher}-${mode}-${tweak} -h $hash -s $size $img $key >/dev/null 2>&1
      record_result $?
    done
  else
    let total=$[int + 1];
    cryptsetup -q luksFormat -i 500 -c ${cipher}-${mode}-${tweak} -h $hash -s $size $img $key >/dev/null 2>&1
    record_result $?
  fi

}

cryptsetup_version="$(cryptsetup --version|awk '{ print $NF }')";
cryptsetup_backend="$(crypt_backend)";
testname="$(echo $cryptsetup_backend | awk '{ print $1 }' | awk -F/ '{ print $1 }' | tr -d '[0-9]')"

echo "cryptsetup: ${cryptsetup_version}"
echo "backend: ${cryptsetup_backend}"
echo "testname: $testname"


img="/tmp/luks-disk.img";
key="/tmp/luks.key";
csv="/tmp/luks-${testname}.csv";
ciphers="aes twofish serpent anubis arc4 blowfish camellia cast5 cast6 des fcrypt seed tnepres tea xtea xeta";
modes="xts cbc pcbc ctr ccm ecb lrw";
tweaks="plain plain64 essiv benbi";
hashes="ripemd128 ripemd256 ripemd320 ripemd160 sha1 sha256 sha384 sha512 whirlpool tiger md_gost94 streebog256 streebog512";
sizes="128 160 192 224 256 384 512";

est="`echo \"${#ciphers} * ${#modes} * ${#tweaks} * ${#hashes} * ${#sizes} \"`"
echo "Estimation: $est"
exit 0

test -f $csv && rm $csv;
dd if=/dev/zero of=${img} bs=4132864 count=1 >/dev/null 2>&1
openssl rand -base64 48 | tr -d '\n' > $key
#/usr/local/bin/random.sh 512 > $key;
total=0;
good=0;



for cipher in $ciphers; do
  for mode  in $modes;   do
    for tweak in $tweaks; do
      for hash in $hashes; do
        for size in $sizes; do

          # anything other than 256 or 512 in XTS mode is automatically invaild.
          if [ $mode = "xts" ]; then
            case $size in
              256|384|512 )
                ;;
              * )
                #echo "skipping ${cipher}-${mode}-${tweak} $hash $size" >/dev/stderr;
                continue;
                ;;
            esac
          fi
          save="$tweak"
          run_crypt ${cipher} ${mode} ${tweak} ${hash} ${size}
          tweak="$save"

        done; # end of size
      done; # end of hash
    done # end of tweak
  done # end of mode
done # end of cipher

echo "Script has tried $total possibilites"
echo "Luks has $good combinations"
