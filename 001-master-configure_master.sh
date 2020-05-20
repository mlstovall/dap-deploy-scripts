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

function validate_complexity() {
    local MASTER_PASS=$1

    CNT=$(echo "$MASTER_PASS" | wc -c)
    CUPPER=$(echo "$MASTER_PASS" | tr -dc A-Z | wc -c)
    CLOWER=$(echo "$MASTER_PASS" | tr -dc a-z | wc -c)
    CDIGIT=$(echo "$MASTER_PASS" | tr -dc 0-9 | wc -c)
    CSPECIAL=$(echo "$MASTER_PASS" | tr -dc "!\"#$%&\'()*+,-.\/:;<=>?@\[\\\]^_\`{|}~" | wc -c)

    local error=0

    if [ "$CNT" -lt 12 ] || [ "$CNT" -gt 128 ]; then error=1;fi
    if [ "$CUPPER" -lt 2 ]; then error=1;fi
    if [ "$CLOWER" -lt 2 ]; then error=1;fi
    if [ "$CDIGIT" -lt 1 ]; then error=1;fi
    if [ "$CSPECIAL" -lt 1 ];then error=1;fi

    if [ "$error" -eq 1 ];then
        echo "Password did not meet complexity requirements:"
        echo " - Between 12-128 characters long"
        echo " - 2 upper case letters"
        echo " - 2 lower case letters"
        echo " - 1 digit"
        echo " - 1 special character in !\"#$%&\'()*+,-.\/:;<=>?@\[\\\]^_\`{|}~"

        return 1
    fi

    return 0
}

capture_password() {
  while true; do
    read -s -p "Admin Password: " MASTER_PASS
    echo ""

    if ! validate_complexity "$MASTER_PASS"; then
      prompt_confirm "Try again?" || exit 1
      continue
    fi

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
