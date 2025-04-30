#!/usr/bin/bash

exec >> pgetinker-update.log 2>&1

source common.sh

if [ "$1" == "refs/heads/main" ]; then bash update-main.sh; fi
if [ "$1" == "refs/heads/develop" ]; then bash update-develop.sh; fi
