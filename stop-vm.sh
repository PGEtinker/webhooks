#!/usr/bin/bash

source common.sh

id="$1"
NEW_VMID="${id: -9}"
RUNNER_TOKEN="$2"
SNIPPETS_DIR="/var/lib/vz/snippets"  # Default snippets directory
USER_DATA_FILE="$SNIPPETS_DIR/user-data-$NEW_VMID.yaml"

# Wait for the clone to shut down
while [ "$(proxmox_ssh "qm status $NEW_VMID" | grep status | awk '{print $2}')" != "stopped" ]; do
    log "Waiting for VM $NEW_VMID to shut down..."
    sleep 5
done
log "VM $NEW_VMID has shut down."

# Destroy the cloned VM
proxmox_ssh "qm destroy $NEW_VMID"
if [ $? -ne 0 ]; then
    log "Failed to destroy clone."
    exit 1
else
    log "VM $NEW_VMID destroyed successfully."
fi
proxmox_ssh "rm -f $USER_DATA_FILE"
