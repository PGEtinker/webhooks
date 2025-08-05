#!/usr/bin/bash

exec >> logs/pgetinker-ci.log 2>&1

source common.sh

ACTION="$1"
ID="$2"
REPO_FULLNAME="$3"
REPO_BRANCH="$4"

if [ "queued" == "$ACTION" ]; then

    log "Retrieve runner registration token."
    TOKEN=$(curl -L \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
        "https://api.github.com/repos/$REPO_FULLNAME/actions/runners/registration-token" 2> /dev/null | jq -r '.token')

    if [ "null" == "$TOKEN" ]; then
        log "Runner token is null. Check PAT."
        exit 1
    fi
    
    log "Write token to $ID."
    echo "$TOKEN" > "$ID"
    
    if [ ! -f "$ID" ]; then
        log "Runner $ID key failed to write."
        exit 1
    fi

    bash start-vm.sh "$ID" "$TOKEN" "$REPO_FULLNAME"
    
    # Do stuff to create the VM.

    exit 0
fi

if [ "in_progress" == "$ACTION" ]; then
    # Don't really know what to do here, if anything.
    exit 0
fi

if [ "completed" == "$ACTION" ]; then
    
    if [ -f "$ID" ]; then
        bash stop-vm.sh "$ID"
        rm "$ID"
    fi
    exit 0
fi

# remove ansi color escape codes
sed -i 's/\x1B\[[0-9;]*[a-zA-Z]//g' logs/pgetinker-ci.log
