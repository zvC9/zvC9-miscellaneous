#!/bin/bash
# Generating self-signed key manually:
 #Country Name (2 letter code) [AU]:RU
 #State or Province Name (full name) [Some-State]:State
 #Locality Name (eg, city) []:City
 #Organization Name (eg, company) [Internet Widgits ...]:Company
 #Organizational Unit Name (eg, section) []:Section
 #Common Name (e.g. server FQDN or YOUR name) []:ca
 #Email Address []:

source bashlib/vars.bash || exit 1


mkdir -p "created_files_for_use/client" || exit 1
pushd    "created_files_for_use/client" || exit 2




# generate self-signed keys
 for name in  firefox ; do
  echo -en "${cert_country_code}\\nState\\nCity\\nCompany\\nSection\\n${client_name}\\n\\n"\
  | openssl req -x509 -newkey rsa:${rsa_bits} -nodes -outform PEM -out \
  ${client_name}.selfsigned.cert.pem -keyout ${client_name}.key.pem -keyform \
  PEM -days $cert_days # -newkey rsa:$bits
  
  echo -en \
   "${cert_country_code}\\nState\\nCity\\nCompany\\nSection\\n${client_name}\\n\\n\\n\\n" |\
   openssl req -new -outform PEM -out ${client_name}.csr.pem -key \
   ${client_name}.key.pem -keyform PEM
  
  #openssl pkcs12 -export -inkey ${name}.key.pem -in ${name}.selfsigned.cert.pem  -out ${name}.key.p12 -name firefox
 done 

popd

exit 0

# Generating certificate signing request manually:
 #Country Name (2 letter code) [AU]:RU
 #State or Province Name (full name) [Some-State]:S
 #Locality Name (eg, city) []:S
 #Organization Name (eg, company) [Internet Widgits Pty Ltd]:S
 #Organizational Unit Name (eg, section) []:S
 #Common Name (e.g. server FQDN or YOUR name) []:S
 #Email Address []:
 #
 #Please enter the following 'extra' attributes
 #to be sent with your certificate request
 #A challenge password []:
 #An optional company name []:

# generate CSRs (certificate signing requests)
 for name in ${netname}-tls-client ; do
  echo -en \
   "RU\\nState\\nCity\\nCompany\\nSection\\n${name}\\n\\n\\n\\n" |\
   openssl req -new -outform PEM -out ${name}.csr.pem -key \
   ${name}.key.pem -keyform PEM
 done

popd

