#!/usr/bin/env bash
##
# generate_root.sh - Generate Self Signed SSL/TLS Certs.
# for Email, Web Servers, etc.
# Copyright (C) 2016 Daniel J. Reidy <dubkat@gmail.com>
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Much was taken directly from the following link. Please visit it for
# proper documention.
# http://pki-tutorial.readthedocs.io/en/latest/simple/#view-results
##

function query() {
  echo -e -n "$(tput setaf 10)* QUERY$(tput sgr0): $(tput setaf 15)${1} $(tput setaf 7)>$(tput setaf 2)>$(tput setaf 10)>$(tput sgr0) "
}

function info() {
  echo -e "$(tput setaf 12)*  INFO$(tput sgr0): $1"
}

function warn() {
  echo -e "$(tput setaf 11)*  WARN$(tput sgr0): $1"
}

function error() {
  echo -e "$(tput setaf 9)* ERROR$(tput sgr0): $1"
}

function fatal() {
  error "$1"
  exit 1
}

function output_conf_email() {
   fatal "Unimplemented."
}


function root_required() {
  if [ $UID -gt 0 ]; then
    fatal "You must be $(tput bold)root$(tput sgr0) to generate a root certificate authority."
  fi
}


function print_usage() {
  ret=$1
  me=$(basename $0);
  cmd=info
  if [ $ret -gt 0 ]; then
    cmd=error
  fi
  #info "$me usage:"
  $cmd "$me usage"
  $cmd "$me root"
  $cmd "$me sign"

  if [ $ret -gt 0 ]; then
    fatal "Invalid or no argument given."
  fi
}

function readin() {
	read input
	echo -n $input
}
function readpass() {
	read -s input
	echo -n $input
}

function create_config() {
	type=$1;
	#local digest;
	#digest_list="$(openssl dgst --help 2>&1 | grep 'to use the' | awk '{ print $1 }' | sed 's/^-//' | xargs)"
	query "Enter a simple (one-word) name for your CA"
	ca_simple="$(readin)"

	query "Enter a password (silent)"
	input_password="$(readpass)"
	echo

	query "Enter your full name."
	user_name="$(readin)"

	query "Enter your email address."
	user_email="$(readin)"

	query "Enter your Orginizaion / Company Name"
	co_name="$(readin)"

	query "Enter your domain, such as example.org"
	co_domain="$(readin)"
	co_domain_top="${co_domain#*.}"
	co_domain_sub="${co_domain%.*}"

	query "Enter your Country name"
	country="$(readin)"
	
	query "Enter your State name"
	state="$(readin)"

	query "Enter your City/Locality"
	city="$(readin)"

	#while [ true ]; do
	#	info "Supported TLS Hash Digests:"
	#	info ">> $digest_list"
	#	query "Enter the desired hashing digest from the above list"
	#	in_digest="$(readin)"
	#	for d in $digest_list; do
	#		if [ "x${in_digest}" = "x${d}" ]; then
	#			digest="${d}"
	#			break 2;
	#		fi
	#	done
	#	error "Invalid Digest: $in_digest"
	#done
	
	info "Generating base directory structure."
	local list="${root_dir}/etc ${root_dir}/ca/root/private ${root_dir}/ca/root/db ${root_dir}/crl ${root_dir}/certs"
	for d in $list; do
		test -d "${d}" || {
		      info "    ${d}"
		      mkdir -p "${d}"
		}
	done
	chmod 700 ${root_dir}/ca/root/private

	
	info "Initialiizng root databases."
  test ! -f ${root_dir}/ca/root/db/root.db           &&
    cp /dev/null ${root_dir}/ca/root/db/root.db      ||:
  test ! -f ${root_dir}/ca/root/db/root.db.attr      &&
    cp /dev/null ${root_dir}/ca/root/db/root.db.attr ||:
  test ! -f ${root_dir}/ca/root/db/root.crt.srl      &&
    echo 01 > ${root_dir}/ca/root/db/root.crt.srl    ||:
  test ! -f ${root_dir}/ca/root/db/root.crl.srl      &&
    echo 01 > ${root_dir}/ca/root/db/root.crl.srl    ||:


  info "$(openssl version): Generating CA Signing Certficates in $root_dir"
  mkdir -p ${root_dir}/ca/signing/private ${root_dir}/ca/signing/db ${root_dir}/crl ${root_dir}/certs
  chmod 700 ${root_dir}/ca/signing/private

  test ! -f ${root_dir}/ca/signing/db/signing.db           &&
    cp /dev/null ${root_dir}/ca/signing/db/signing.db      ||:
  test ! -f ${root_dir}/ca/signing/db/signing.db.attr      &&
    cp /dev/null ${root_dir}/ca/signing/db/signing.db.attr ||:
  test ! -f ${root_dir}/ca/signing/db/signing.crt.srl      &&
    echo 01 > ${root_dir}/ca/signing/db/signing.crt.srl    ||:
  test ! -f ${root_dir}/ca/signing/db/signing.crl.srl      &&
    echo 01 > ${root_dir}/ca/signing/db/signing.crl.srl    ||:


cat<<ROOTCA > "${root_dir}/etc/root.conf"
# Simple Root CA

# The [default] section contains global constants that can be referred to from
# the entire configuration file. It may also hold settings pertaining to more
# than one openssl command.

[ default ]
ca                      = root     # CA name
dir                     = .           # Top dir

# The next part of the configuration file is used by the openssl req command.
# It defines the CA's key pair, its DN, and the desired extensions for the CA
# certificate.

[ req ]
default_bits            = 4096                  # RSA key size
encrypt_key             = yes                   # Protect private key
default_md              = sha512                # MD to use
utf8                    = yes                   # Input is UTF-8
string_mask             = utf8only              # Emit UTF-8 strings
prompt                  = no                    # Don't prompt for DN
distinguished_name      = ca_dn                 # DN section
req_extensions          = ca_reqext             # Desired extensions
input_password          = $input_password
output_password         = $input_password


[ ca_dn ]
0.domainComponent       = "$co_domain_top"
1.domainComponent       = "$co_domain_sub"
organizationName        = "$co_name"
organizationalUnitName  = "$co_name Root CA"
commonName              = "$co_name Root CA"
countryName		= "$country"
stateOrProvinceName	= "$state"
localityName            = "$city"


[ ca_reqext ]
keyUsage                = critical,keyCertSign,cRLSign
basicConstraints        = critical,CA:true
subjectKeyIdentifier    = hash

# The remainder of the configuration file is used by the openssl ca command.
# The CA section defines the locations of CA assets, as well as the policies
# applying to the CA.

[ ca ]
default_ca              = root               # The default CA section

[ root ]
certificate             = $root_dir/ca/root.crt             # The CA cert
private_key             = $root_dir/ca/root/private/root.key # CA private key
new_certs_dir           = $root_dir/ca/root                 # Certificate archive
serial                  = $root_dir/ca/root/db/root.crt.srl  # Serial number file
crlnumber               = $root_dir/ca/root/db/root.crl.srl  # CRL number file
database                = $root_dir/ca/root/db/root.db       # Index file

unique_subject          = no                    # Require unique subject
default_days            = 3652                  # How long to certify for
default_md              = sha512                # MD to use
policy                  = match_pol             # Default naming policy
email_in_dn             = no                    # Add email to cert DN
preserve                = no                    # Keep passed DN ordering
name_opt                = ca_default            # Subject DN display options
cert_opt                = ca_default            # Certificate display options
copy_extensions         = none                  # Copy extensions from CSR
x509_extensions         = signing_ca_ext        # Default cert extensions
default_crl_days        = 730                   # How long before next CRL
crl_extensions          = crl_ext               # CRL extensions

# Naming policies control which parts of a DN end up in the certificate and
# under what circumstances certification should be denied.

[ match_pol ]
domainComponent         = match                 # Must match '$co_domain'
organizationName        = match                 # Must match '$co_name'
organizationalUnitName  = optional              # Included if present
commonName              = supplied              # Must be present

[ any_pol ]
domainComponent         = optional
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = optional
emailAddress            = optional

# Certificate extensions define what types of certificates the CA is able to
# create.

[ root_ext ]
keyUsage                = critical,keyCertSign,cRLSign
basicConstraints        = critical,CA:true
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always

[ signing_ca_ext ]
keyUsage                = critical,keyCertSign,cRLSign
basicConstraints        = critical,CA:true,pathlen:0
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always

# CRL extensions exist solely to point to the CA certificate that has issued
# the CRL.

[ crl_ext ]
authorityKeyIdentifier  = keyid:always

ROOTCA

cat<<SIGNING > "${root_dir}/etc/signing.conf"
# Simple Signing CA

# The [default] section contains global constants that can be referred to from
# the entire configuration file. It may also hold settings pertaining to more
# than one openssl command.

[ default ]
ca                      = signing            # CA name
dir                     = .                     # Top dir

# The next part of the configuration file is used by the openssl req command.
# It defines the CA's key pair, its DN, and the desired extensions for the CA
# certificate.

[ req ]
default_bits            = 4096                  # RSA key size
encrypt_key             = yes                   # Protect private key
default_md              = sha512                # MD to use
utf8                    = yes                   # Input is UTF-8
string_mask             = utf8only              # Emit UTF-8 strings
prompt                  = no                    # Don't prompt for DN
distinguished_name      = ca_dn                 # DN section
req_extensions          = ca_reqext             # Desired extensions
input_password          = $input_password
output_password         = $input_password

[ ca_dn ]
0.domainComponent       = "$co_domain_top"
1.domainComponent       = "$co_domain_sub"
organizationName        = "$co_name"
organizationalUnitName  = "$co_name Signing CA"
commonName              = "$co_name Signing CA"
countryName		= "$country"
stateOrProvinceName	= "$state"
localityName            = "$city"


[ ca_reqext ]
keyUsage                = critical,keyCertSign,cRLSign
basicConstraints        = critical,CA:true,pathlen:0
subjectKeyIdentifier    = hash

# The remainder of the configuration file is used by the openssl ca command.
# The CA section defines the locations of CA assets, as well as the policies
# applying to the CA.

[ ca ]
default_ca              = signing_ca                       # The default CA section

[ signing_ca ]
certificate             = $root_dir/ca/root.crt                    # The CA cert
private_key             = $root_dir/ca/root/private/root.key        # CA private key
new_certs_dir           = $root_dir/ca/root                        # Certificate archive
serial                  = $root_dir/ca/root/db/root.crt.srl  # Serial number file
crlnumber               = $root_dir/ca/root/db/root.crl.srl  # CRL number file
database                = $root_dir/ca/root/db/root.db       # Index file
unique_subject          = no                               # Require unique subject
default_days            = 730                              # How long to certify for
default_md              = sha512                           # MD to use
policy                  = match_pol                        # Default naming policy
email_in_dn             = no                               # Add email to cert DN
preserve                = no                               # Keep passed DN ordering
name_opt                = ca_default                       # Subject DN display options
cert_opt                = ca_default                       # Certificate display options
copy_extensions         = copy                             # Copy extensions from CSR
x509_extensions         = email_ext                        # Default cert extensions
default_crl_days        = 7                                # How long before next CRL
crl_extensions          = crl_ext                          # CRL extensions

# Naming policies control which parts of a DN end up in the certificate and
# under what circumstances certification should be denied.

[ match_pol ]
domainComponent         = match                 # Must match '$co_domain'
organizationName        = match                 # Must match '$co_name'
organizationalUnitName  = optional              # Included if present
commonName              = supplied              # Must be present

[ any_pol ]
domainComponent         = optional
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = optional
emailAddress            = optional

# Certificate extensions define what types of certificates the CA is able to
# create.

[ email_ext ]
keyUsage                = critical,digitalSignature,keyEncipherment
basicConstraints        = CA:false
extendedKeyUsage        = emailProtection,clientAuth
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always

[ server_ext ]
keyUsage                = critical,digitalSignature,keyEncipherment
basicConstraints        = CA:false
extendedKeyUsage        = serverAuth,clientAuth
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always

# CRL extensions exist solely to point to the CA certificate that has issued
# the CRL.

[ crl_ext ]
authorityKeyIdentifier  = keyid:always

SIGNING

cat<<EMAIL > $root_dir/etc/email.conf
# Email certificate request

# This file is used by the openssl req command. Since we cannot know the DN in
# advance the user is prompted for DN information.

[ default ]


[ req ]
default_bits            = 4096                  # RSA key size
encrypt_key             = yes                   # Protect private key
default_md              = sha512                # MD to use
utf8                    = yes                   # Input is UTF-8
string_mask             = utf8only              # Emit UTF-8 strings
prompt                  = yes                   # Prompt for DN
distinguished_name      = email_dn              # DN template
req_extensions          = email_reqext          # Desired extensions
input_password          = $input_password
output_password         = $input_password



[ email_dn ]
0.domainComponent_default = "$co_domain_top"
1.domainComponent_default = "$co_domain_sub"
2.domainComponent_default = "$ca_name"
organizationName_default = "$co_name"
organizationalUnitName_default = "$co_name Services"
commonName_default = "$user_name"
emailAddress_default = "$user_email"
countryName_default = "$country"
stateOrProvinceName_default = "$state"
localityName_default = "$city"
emailAddress_default = "$user_email"

countryName		= "1. Country Name             (eg, US) "
stateOrProvinceName	= "2. State/Province           (eg, NY) "
localityName            = "3. City / Locality          (eg, Albany) "
0.domainComponent       = "4. Domain Component         (eg, $co_domain_top) "
1.domainComponent       = "5. Domain Component         (eg, $co_domain_sub) "
#2.domainComponent       = "6. Domain Component         (eg, $ca_name) "
organizationName        = "7. Organization Name        (eg, $co_name) "
organizationalUnitName  = "8. Organizational Unit Name (eg, $co_name) "
commonName              = "9. Common Name              (eg, $user_name) "
commonName_max          = 128
emailAddress            = "10. Email Address            (eg, name@fqdn)"
emailAddress_max        = 40

[ email_reqext ]
keyUsage                = critical,digitalSignature,keyEncipherment
extendedKeyUsage        = emailProtection,clientAuth
subjectKeyIdentifier    = hash
subjectAltName          = email:move

EMAIL

cat<<SERVER > $root_dir/etc/server.conf
# TLS server certificate request

# This file is used by the openssl req command. The subjectAltName cannot be
# prompted for and must be specified in the SAN environment variable.

[ default ]
SAN                     = DNS:$co_domain        # Default value

[ req ]
default_bits            = 4096                  # RSA key size
encrypt_key             = no                    # Protect private key
default_md              = sha512                # MD to use
utf8                    = yes                   # Input is UTF-8
string_mask             = utf8only              # Emit UTF-8 strings
prompt                  = yes                   # Prompt for DN
distinguished_name      = server_dn             # DN template
req_extensions          = server_reqext         # Desired extensions

[ server_dn ]
0.domainComponent_default = "$co_domain_top"
1.domainComponent_default = "$co_domain_sub"
2.domainComponent_default = "$ca_simple"
organizationalUnitName_default = "$co_name CA"
commonName_default = "$user_name"
emailAddress_default = "$user_email"
countryName_default = "$country"
stateOrProvinceName_default = "$state"
localityName_default = "$city"
organizationName_default = "$co_name"

organizationName        = "1. Organization Name        (eg, $co_name) "
organizationalUnitName  = "2. Organizational Unit Name (eg, $co_name CA) "

countryName		= "3. Country Name                     (eg, US) "
stateOrProvinceName	= "4. State/Province 2 Letter ISO Code (eg, NY) "
localityName            = "5. City / Locality              (eg, Albany) "
0.domainComponent       = "6. Domain Component                (eg, com) "
1.domainComponent       = "7. Domain Component             (eg, google) "
#2.domainComponent       = "8. Domain Component         (eg, $ca_simple) "
commonName              = "9. Common Name              (eg, $hostname) "
commonName_max          = 64

[ server_reqext ]
keyUsage                = critical,digitalSignature,keyEncipherment
extendedKeyUsage        = serverAuth,clientAuth
subjectKeyIdentifier    = hash
subjectAltName          = \$ENV::SAN

SERVER


}

function generate_root() {
  root_required

  info "$(openssl version): Generating CA Root Certficates in $root_dir."

  if [ ! -d "${root_dir}/etc" ]; then
    create_config
  fi

  info "Generating root key."
  openssl req \
    -new \
    -config ${root_dir}/etc/root.conf \
    -out ${root_dir}/ca/root.csr \
    -keyout ${root_dir}/ca/root/private/root.key || {
    fatal "Failed to create root.key in ${root_dir}/ca/root/private";
  }

  info "Generation Signing key."
  openssl req \
    -new \
    -config ${root_dir}/etc/signing.conf \
    -out ${root_dir}/ca/signing.csr \
    -keyout ${root_dir}/ca/signing/private/signing.key || {
     	fatal "Failed to create req signing in ${root_dir}/ca/private";
    }

  info "Generating root self signed certificate."
  openssl ca -selfsign \
    -config ${root_dir}/etc/root.conf \
    -in ${root_dir}/ca/root.csr \
    -out ${root_dir}/ca/root.crt \
    -extensions root_ext || {
    fatal "Failed to create self-signed certificate in ${root_dir}/ca";
  }


  info "Generating Signing Root."
  openssl ca \
    -config ${root_dir}/etc/root.conf \
    -in ${root_dir}/ca/signing.csr \
    -out ${root_dir}/ca/signing.crt \
    -extensions signing_ca_ext || {
	fatal "Failed to create ca signing root in ${root_dir}/ca/private";
    }

   info "Creating PKCS#7 Bundle"
   openssl crl2pkcs7 -nocrl \
     -certfile $root_dir/ca/signing.crt \
     -certfile $root_dir/ca/root.crt \
     -out $root_dir/ca/${ca_name}-signing-ca-chain.p7c \
     -outform der

    info "Creating ${ca_name}-signing-authority-chain.pem"
    cat $root_dir/ca/signing.crt $root_dir/ca/root.crt > $root_dir/ca/${ca_name}-signing-authority-chain.pem

}

function generate_email() {
	query "Enter Name"
	name="$(readin)"
	info "Creating Cert Req..."
	openssl req -new \
          -config $root_dir/etc/email.conf \
    	  -out $root_dir/certs/${name// /_}.csr \
          -keyout $root_dir/certs/${name// /_}.key

	info "Creating Certificate Auth"
	openssl ca \
    	  -config $root_dir/etc/signing.conf \
          -in $root_dir/certs/${name// /_}.csr \
          -out $root_dir/certs/${name// /_}.crt \
          -extensions email_ext

	info "Creating x509..."
	openssl x509 \
	  -in $root_dir/certs/${name// /_}.crt \
   	  -out $root_dir/certs/${name// /_}.cer \
	  -outform der

	info "Creating Revocation List"
	openssl crl \
	  -in $root_dir/crl/signing.crl \
          -out $root_dir/crl/signing.crl \
          -outform der

	info "Creating PKCS#12 bundle"
	openssl pkcs12 -export \
	    -name "$user_name" \
	    -inkey $root_dir/certs/${name// /_}.key \
	    -in $root_dir/certs/${name// /_}.crt \
	    -out $root_dir/certs/${name// /_}.p12

	info "Creating Key+Cert PEM for ${name}"
	cat $root_dir/certs/${name// /_}.key \
	  $root_dir/certs/${name// /_}.crt > \
          $root_dir/certs/${name// /_}.pem

}

function generate_tls() {
	info "Generating Server TLS Certificates"
	hostname="$(hostnamectl --static)"
	query "Enter Server Hostname"
	hostname="$(readin)"
	SAN=DNS:${hostname} \
	openssl req -new \
    		-config $root_dir/etc/server.conf \
	    	-out $root_dir/certs/${hostname}.csr \
	    	-keyout $root_dir/certs/${hostname}.key

	openssl ca \
	    -config $root_dir/etc/signing.conf \
	    -in $root_dir/certs/${hostname}.csr \
	    -out $root_dir/certs/${hostname}.crt \
	    -extensions server_ext

}

: ${SSL_ROOT:=/usr/local/etc/ssl}
root_dir="${SSL_ROOT}"

info "SSL_ROOT is set to $root_dir."
info "If you wish to change this, simply export SSL_ROOT=/your/chosen/path"

case $1 in
  setup   ) generate_root; ;;
  email  ) generate_email; ;;
  tls    ) generate_tls; ;;
  dercrl ) generate_dercrl; ;;
  examine) examine_certs; ;;
  usage|-h|--help  ) print_usage 0; ;;
  * )      print_usage 1; ;;
esac
