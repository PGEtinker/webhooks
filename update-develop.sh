#!/usr/bin/bash

source common.sh

log "#### Spin up maintenance page."
cd "$APPS_BASE_DIRECTORY/pgetinker-maintenance"
docker compose up -d
log "## Done."

log "#### Switch next.pgetinker.com proxy host to http://pgetinker.maintenance:80."
npm_update_host "next.pgetinker.com" "http" "pgetinker.maintenance" "80"
if [ ! $? -eq 0 ]; then
    log "An error occurred while trying to update hosts."
    exit 1
fi
log "## Done."

log "#### Spin down pgetinker.next."
cd "$APPS_BASE_DIRECTORY/pgetinker-next"
scripts/pgetinker down
log "## Done."

log "#### Run pgetinker updates."
scripts/pgetinker update ci
log "## Done."

log "#### Spin up pgetinker.next."
scripts/pgetinker up -d
log "## Done."

log "#### Switch next.pgetinker.com proxy host to http://pgetinker.next:80."
npm_update_host "next.pgetinker.com" "http" "pgetinker.next" "80"
if [ ! $? -eq 0 ]; then
    log "An error occurred while trying to update hosts."
    exit 1
fi
log "## Done."

log "#### Spin down maintenance page."
cd "$APPS_BASE_DIRECTORY/pgetinker-maintenance"
docker compose down
log "## Done."
