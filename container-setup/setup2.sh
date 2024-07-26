#!/usr/bin/bash

# Install ifupdown2, it will complete network configuration tnis time
apt install -y ifupdown2
apt install -y proxmox-ve # freenas-proxmox

# Create the admin user
pveum user add admin@pam
pveum acl modify / --roles Administrator --users admin@pam

# Finalize
apt autoremove -y
echo > /root/.bashrc
rm -rf /root/setup
systemctl reboot
