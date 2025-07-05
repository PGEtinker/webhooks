# Notes and Snippets

This page contains a series of notes and script snippets
that are nice to have a round for reference or straight-up
copy/paste


## Clean VM

This series of commands are useful as the last commands
run on a VM that you intend to make a template for cloning.

```bash
sudo cloud-init clean --logs
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo rm -f /etc/ssh/ssh_host_*
sudo find /var/log -type f -exec truncate -s 0 {} \;
sudo apt-get clean
rm -rf /home/$USER/.ssh/*
rm -f /home/$USER/.bash_history
sudo poweroff
```

## Network Settings

```bash
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
```