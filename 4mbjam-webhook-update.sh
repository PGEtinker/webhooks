#!/usr/bin/bash

exec >> logs/4mbjam-update.log 2>&1

source common.sh

log "Webhook triggered" "$@"

if [ "$1" == "refs/heads/main" ]; then bash 4mbjam-update-main.sh; fi
if [ "$1" == "refs/heads/develop" ]; then bash 4mbjam-update-develop.sh; fi

# remove ansi color escape codes
sed -i 's/\x1B\[[0-9;]*[a-zA-Z]//g' logs/4mbjam-update.log
