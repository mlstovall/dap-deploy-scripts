#!/usr/bin/env bash

. config.sh

# set -x

# ===============================
# = DO NOT EDIT BELOW THIS LINE =
# ===============================

[[ -d $cert_dir ]] || mkdir $cert_dir
[[ -d $cert_config_dir ]] || mkdir $cert_config_dir
[[ -d $cert_output_dir ]] || mkdir $cert_output_dir

# Set the Request DN values
dn_props=$(set | grep m_dn_ | sort | awk -F"_" '{print $NF}' | sed "s/'//g")

# Set the Alternate Names values

alt_names=""
c=0
for i in $(echo $master_alt_names | tr "," "\n");do
    alt_names="$alt_names\nDNS.$c=$i"
    ((c++))
done

# Generate the request OpenSSL Config Files

cat << EOF > $master_cert_config_file
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
$dn_props
CN=$m_subject

[ req_ext ]
nsCertType = server, client
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName=@alt_names

EOF

echo -e "[ alt_names ]$alt_names" >> $master_cert_config_file


# Generate private key for master certificate
if ! test -f "$master_key_path"; then
  openssl genrsa -out $master_key_path 2048
else
    echo -e "\n===================================\n=== WARNING - WARNING - WARNING === \n==================================="
    echo -e " - A private key already exists at $master_key_path!\n - If you want to use that, safely ignore this warning."
    echo -e " - If you wish to use a new key, please delete $master_key_path\n - and run this script again!"
fi

# Generate CSR for master certificate
openssl req \
    -config $master_cert_config_file \
    -key $master_key_path \
    -new -sha256 -nodes \
    -out $master_csr_file_path

# Follower - Generate the request OpenSSL Config Files

cat << EOF > $follower_cert_config_file
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
$dn_props
CN=$f_subject

[ req_ext ]
nsCertType = server, client
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
EOF

# Generate the key for the follower certificate
if ! test -f "$follower_key_path"; then
  openssl genrsa -out $follower_key_path 2048
else
    echo -e "\n===================================\n=== WARNING - WARNING - WARNING === \n==================================="
    echo -e " - A private key already exists at $follower_key_path!\n - If you want to use that, safely ignore this warning."
    echo -e " - If you wish to use a new key, please delete $follower_key_path\n - and run this script again!"
fi

# Generate CSR for follower certificate
openssl req \
    -config $follower_cert_config_file \
    -key $follower_key_path \
    -new -sha256 -nodes \
    -out $follower_csr_file_path

# Display the results

echo ""
echo "==================================="
echo "=== Master CSR: $master_csr_file_path"
echo "=== Master Key File: $master_key_path"
echo "==================================="
cat $master_csr_file_path

echo "==================================="
echo "=== Follower CSR: $follower_csr_file_path"
echo "=== Follower Key File: $follower_key_path"
echo "==================================="
cat $follower_csr_file_path
