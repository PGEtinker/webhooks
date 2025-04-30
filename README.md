# Webhooks

This repository is part of the PGEtinker infrastructure and has no
use outside of that environment. However, if you're intersted in
how things are accomplished on the hosting side of things, here's
a big portion of how it's managed. If you have questions, I'll
answer them but this is not provided as a project in and of itself.

## What does what?

### Apps

I refer to directories containing a docker compose project an "app".

- nginx-proxy-manager: for reverse proxy and SSL terminations
- pgetinker: https://pgetinker.com
- pgetinker-next: https://next.pgetinker.com
- pgetinker-maintenance: the service that runs in place of
pgetinker or pgetinker-next when they are being updated.
- webhooks: this repository!

There are more, but none of them matter for the purposes of this
repo.

### hooks.json

This system relies on a software called webhook which can be
to match specific webhooks and when there's a match it fires
off the configured script.

### pgetinker-ci.sh

This script is fired when a github action is queued, in progress,
or is completed.

- Queue: configures and spawns a VM for the self hosted github
action runner. This VM processes the job and then shuts down.
(see start-vm.sh)

- In Progress: is not currently handled.

- Completed: waits for the VM to shutdown, then destroys it.
(see stop-vm.sh)

### pgetinker-update.sh

This script is fired when there is a push to the main or develop
branch on the github repository. Fires a branch dependent script.

- Main: when there's a push to the main branch, this signifies a
new release and the site https://pgetinker.com needs to be updated.
This script will put the site into maintenance mode, perform the
update, and bring the site back online. (see update-main.sh)

- Develop: for the ease of development and testing, all pushes to
the develop branch are deployed on the site https://next.pgetinker.com.
This script will put the site into maintenance mode, perform the
update, and bring the site back online. (see update-develop.sh)
This site is isolated from production and does not affect the state of
the main site (eg: shared code, cacheing, etc).
