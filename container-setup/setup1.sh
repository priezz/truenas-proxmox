#!/usr/bin/bash
echo -e '\nSet the "root" user password:'
passwd
echo
adduser admin
usermod -aG sudo admin

cat > /etc/hosts <<EOF
127.0.0.1				localhost
::1							localhost ip6-localhost ip6-loopback
ff02::1					ip6-allnodes
ff02::2					ip6-allrouters
{{CONTAINER_IP}}	{{HOSTNAME}} {{HOSTNAME}}.local
EOF

mkdir -p /etc/network
cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

# Host network
auto host0
iface host0 inet manual
    mtu {{MTU}}

# Bridge for Virtual Machines
auto vmbr0
iface vmbr0 inet static
    metric 50
    address {{CONTAINER_IP}}/24
    gateway {{GATEWAY_IP}}
    mtu {{MTU}}
    bridge-ports host0
    bridge-stp off
    bridge-fd 0
EOF

mkdir -p /etc/systemd/system/lxcfs.service.d
cat > /etc/systemd/system/lxcfs.service.d/override.conf <<EOF
[Unit]
ConditionVirtualization=
ConditionVirtualization=container
EOF

apt update
apt install -y bridge-utils ca-certificates chrony cron curl dbus dbus-broker ksmtuned open-iscsi openssh-server openvswitch-switch systemd-container wget whiptail postfix
install -m 0755 -d /etc/apt/keyrings
# mkdir -p /dev/pts
# chown 755 /dev/pts
mkdir -p /etc/apt/preferences.d
mkdir -p /var/lib/lxcfs
ln -sf /lib/systemd/system/systemd-networkd.service /etc/systemd/system/dbus-org.freedesktop.network1.service
ln -sf /lib/systemd/system/systemd-resolved.service /etc/systemd/system/dbus-org.freedesktop.resolve1.service
ln -sf /lib/systemd/system/networking.service /etc/systemd/system/multi-user.target.wants/networking.service
ln -sf /lib/systemd/system/networking.service /etc/systemd/system/network-online.target.wants/networking.service
#ln -sf /usr/lib/systemd/user/dbus-broker.service /etc/systemd/user/dbus.service
#ln -sf /lib/systemd/system/dbus-broker.service /etc/systemd/system/dbus.service
/lib/systemd/systemd-sysv-install enable dbus

# Add Proxmox repositories
echo 'deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription' > /etc/apt/sources.list.d/pve-install-repo.list
echo 'deb http://download.proxmox.com/debian/ceph-reef bookworm no-subscription' > /etc/apt/sources.list.d/ceph.list
wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg

# # Install TrueNAS plugin for Proxmox VE
# keyring_location=/usr/share/keyrings/ksatechnologies-truenas-proxmox-testing-keyring.gpg
# curl -1sLf 'https://dl.cloudsmith.io/public/ksatechnologies/truenas-proxmox-testing/gpg.CACC9EE03F2DFFCC.key' |  gpg --dearmor >> ${keyring_location}
# cat << EOF > /etc/apt/sources.list.d/ksatechnologies-testing-repo.list
# # Source: KSATechnologies
# # Site: https://cloudsmith.io
# # Repository: KSATechnologies / truenas-proxmox-testing
# # Description: TrueNAS plugin for Proxmox VE - Testing
# deb [signed-by=${keyring_location}] https://dl.cloudsmith.io/public/ksatechnologies/truenas-proxmox-testing/deb/debian any-version main
# EOF

apt update
apt full-upgrade -y

# Install ifupdown2, it will fail to configure
apt install -y ifupdown2

reboot
