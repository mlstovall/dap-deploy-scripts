#!/usr/bin/env bash

. config.sh

#####
# Capture 'admin' password
#####

echo -n "Admin Pass: "
read -s master_pass
echo
echo -n "Confirm: "
read -s confirm_pass
echo

if [ "$master_pass" != "$confirm_pass" ];then
    echo "Passwords do not match. Please try again."
    exit 1
fi

#####
# Configure the master node
#####

docker exec $container_name \
    evoke configure master \
    --accept-eula \
    -h $master_host_fqdn \
    -p $master_pass \
    --master-altnames="$master_alt_names" \
    $org_account
