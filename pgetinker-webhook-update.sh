#!/usr/bin/bash

exec >> logs/pgetinker-update.log 2>&1

source common.sh

if [ "$1" == "refs/heads/main" ]; then bash pgetinker-update-main.sh; fi
if [ "$1" == "refs/heads/develop" ]; then bash pgetinker-update-develop.sh; fi

# remove ansi color escape codes
sed -i 's/\x1B\[[0-9;]*[a-zA-Z]//g' logs/pgetinker-update.log
