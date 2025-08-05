#!/usr/bin/bash
exec >> logs/pgetinker-wiki.log 2>&1

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

# remove ansi color escape codes
sed -i 's/\x1B\[[0-9;]*[a-zA-Z]//g' logs/pgetinker-wiki.log
