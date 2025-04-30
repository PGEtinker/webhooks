#!/usr/bin/bash

source common.sh

id="$1"
NEW_VMID="${id: -9}"


RUNNER_TOKEN="$2"
REPO_FULLNAME="$3"

SNIPPETS_DIR="/var/lib/vz/snippets"  # Default snippets directory
USER_DATA_FILE="$SNIPPETS_DIR/user-data-$NEW_VMID.yaml"

USER_DATA=$(cat << EOF
#cloud-config
hostname: ed-$NEW_VMID
users:
  - name: $RUNNER_USER
    plain_text_passwd: $RUNNER_PASSWORD
    lock_passwd: false
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']

write_files:
  - path: /start-runner.sh
    content: |
      #!/usr/bin/bash
      cd /actions-runner
      ./config.sh --url "https://github.com/$REPO_FULLNAME" --token "$RUNNER_TOKEN" --name "ed-$NEW_VMID" --ephemeral --unattended
      ./run.sh
    permissions: '0755'

runcmd:
  - docker-cache-load
  - sudo -u $RUNNER_USER bash /start-runner.sh
  - docker-cache-save
  - shutdown -h now
EOF
)

proxmox_ssh "echo \"$USER_DATA\" > $USER_DATA_FILE"

# Create linked clone
proxmox_ssh "qm clone $TEMPLATE_VMID $NEW_VMID -name ed-$NEW_VMID -full 0"
if [ $? -ne 0 ]; then
    proxmox_ssh "rm -f $USER_DATA_FILE"
    log "Failed to create clone."
    exit 1
fi

# Set cloud-init data with custom user data
proxmox_ssh "qm set $NEW_VMID \
    --cicustom \"user=local:snippets/user-data-$NEW_VMID.yaml\""
if [ $? -ne 0 ]; then
    log "Failed to set cloud-init data."
    proxmox_ssh "qm destroy $NEW_VMID"
    proxmox_ssh "rm -f $USER_DATA_FILE"
    exit 1
fi

# Start the cloned VM (optional, remove if not needed)
proxmox_ssh "qm start $NEW_VMID"
