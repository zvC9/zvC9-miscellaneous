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

#mkdir -p "CA-files" || exit 1

## created_files_for_use/client/${client_name}.csr.pem

# generate self-signed key for CA
 for name in CA  ; do
  openssl x509 -req -CA "CA-files/${name}.selfsigned.cert.pem" -CAkey "CA-files/${name}.key.pem" \
        -CAserial "CA-files/CA.serial.srl" \
        -CAcreateserial -out "created_files_for_use/client/${client_name}.ca-signed.cert.pem" -outform PEM \
        -inform PEM -in "created_files_for_use/client/${client_name}.csr.pem"  -days $cert_days || error openssl 3
 done


#popd

exit 0

mkdir -p "created_files_for_use/client/generated/${netname}" || error "mkdir" 3
mkdir -p "created_files_for_use/server/generated/${netname}" || error "mkdir" 4
cp -fv "workdir/${netname}/${netname}-ca.selfsigned.cert.pem" "created_files_for_use/client/generated/${netname}/" || error cp 5
cp -fv "workdir/${netname}/${netname}-ca.selfsigned.cert.pem" "created_files_for_use/server/generated/${netname}/" || error cp 6


