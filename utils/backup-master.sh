#!/usr/bin/env bash

if [ "$(curl -sk https://localhost/info | jq -r .configuration.conjur.role)" == "master" ];then
    docker exec dap evoke backup
fi
