#!/usr/bin/bash

source common.sh

cd "$APPS_BASE_DIRECTORY/4mbjam"
log "$APPS_BASE_DIRECTORY"
log "$(pwd)"

log "#### Pull latest repo"
(cd website; git pull;)
log "## Done."

log "#### Build with Zola"
(cd website; zola build --base-url https://4mbjam.dev)
log "## Done."

log "#### Spin up 4mbjam."
docker compose restart
log "## Done."
