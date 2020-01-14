#!/usr/bin/env bash

set -x

CONJUR_CLI_IMAGE="cyberark/conjur-cli:5"
MASTER_LB=localhost

# 
docker run --name cli-util --rm --entrypoint /bin/bash $CONJUR_CLI_IMAGE -c \
    "curl -sk https://$MASTER_LB/info | jq -c '.configuration.conjur.hostname'"
