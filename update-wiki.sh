#!/usr/bin/bash
exec >> pgetinker-update.log 2>&1

source common.sh

log "#### Pull wiki on pgetinker.next."
cd "$APPS_BASE_DIRECTORY/pgetinker-next"
(cd services/wiki; git pull)
log "## Done."

log "#### Generate wiki on pgetinker.next."
scripts/pgetinker restart wiki
log "## Done."

log "#### Pull wiki on pgetinker.main."
cd "$APPS_BASE_DIRECTORY/pgetinker"
(cd services/wiki; git pull)
log "## Done."

log "#### Generate wiki on pgetinker.main."
scripts/pgetinker restart wiki
log "## Done."
