#!/usr/bin/env bash

. config.sh

MASTER_PASS=""

#####
# Capture 'admin' password
#####

prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; return 0 ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac
  done
}

capture_password() {
  while true; do
    read -s -p "Admin Password: " MASTER_PASS
    echo ""
    read -s -p "Confirm Pass: " MASTER_PASS1
    echo ""
    if [ "$MASTER_PASS" != "$MASTER_PASS1" ]; then
      prompt_confirm "Pass and confirm pass do not match. Try again?" || exit 1
      continue
    fi
    unset MASTER_EPV_PASS1
    break
  done
}

run_container() {
  docker exec $container_name \
    evoke configure master \
    --accept-eula \
    -h "$master_host_fqdn" \
    -p "$MASTER_PASS" \
    --master-altnames="$master_alt_names" \
    "$org_account"
}

capture_password
run_container
