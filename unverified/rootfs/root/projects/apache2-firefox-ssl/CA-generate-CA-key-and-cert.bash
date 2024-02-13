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



#mkdir -p "workdir/${netname}/server" || exit 1
#mkdir -p "workdir/${netname}/client" || exit 1

#mkdir -p "workdir/${netname}" || exit 1
#pushd    "workdir/${netname}" || exit 2

mkdir -p "CA-files" || exit 1
mkdir -p "created_files_for_use/client" || exit 2

# generate self-signed key for CA
 for name in CA  ; do
  echo -en "${cert_country_code}\\nState\\nCity\\nCompany\\nSection\\n${name}\\n\\n"\
  | openssl req -x509  -newkey rsa:$rsa_bits -nodes -outform PEM -out \
  "CA-files/${name}.selfsigned.cert.pem" -keyout "CA-files/${name}.key.pem" -keyform \
  PEM -days $cert_days
 done


#popd

exit 0

mkdir -p "created_files_for_use/client/generated/${netname}" || error "mkdir" 3
mkdir -p "created_files_for_use/server/generated/${netname}" || error "mkdir" 4
cp -fv "workdir/${netname}/${netname}-ca.selfsigned.cert.pem" "created_files_for_use/client/generated/${netname}/" || error cp 5
cp -fv "workdir/${netname}/${netname}-ca.selfsigned.cert.pem" "created_files_for_use/server/generated/${netname}/" || error cp 6


