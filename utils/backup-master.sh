#!/usr/bin/env bash

RETENTION_DAYS=30

if [ "$(curl -sk https://localhost/info | jq -r .role)" == "master" ];then
  # delete backups older than 30 days
  find /opt/conjur/backup -maxdepth 1 -type f -mtime +$RETENTION_DAYS -print | grep Z.tar.xz.gpg | xargs /bin/rm -f
  # run the backup
  docker exec dap evoke backup
fi
