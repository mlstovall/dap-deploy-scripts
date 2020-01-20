#!/usr/bin/env bash

# set -x

CONJUR_CLI_IMAGE="conjurinc/cli5"
MASTER_LB=localhost

if [ "$#" == "1" ];then
    MASTER_LB=$1
fi

# 
docker run --name cli-util --rm --entrypoint /bin/bash $CONJUR_CLI_IMAGE -c \
    "curl -sk https://$MASTER_LB/health | \
    jq -rc '.database.replication_status | 
    if .pg_stat_replication | length != 0 then 
        .pg_stat_replication[] | { IP: .client_addr, Type: .application_name, Sync: .sync_state } 
    else 
        \"No replication clients found.\" 
    end'"
