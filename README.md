# truenas-proxmox

### Running Proxmox in a TrueNAS nspawn container

Thanks to @Jip-Hop and his [jailmaker](https://github.com/Jip-Hop/jailmaker) it
became possible to run nspawn containers in an easy way. This repository
contains instructions and scripts to install Proxmox.

Run in the host:

```
cd ~
git clone https://github.com/priezz/truenas-proxmox
cd truenas-proxmox
```

**Note 1:** Do remember to set `HOSTNAME`, `NETWORK`, `HOST_IP`, `CONTAINER_IP`,
`GATEWAY_IP` and `NAME_SERVERS` in the commands below to your desired values.

```
export HOSTNAME='proxmox'
export NETWORK='192.168.192'
export HOST_IP="$NETWORK.19"
export CONTAINER_IP="$NETWORK.20"
export GATEWAY_IP="$NETWORK.1"
export NAME_SERVERS="$NETWORK.1"
```

**Note 2:** `jlmkr` command should be available. See the [instructions](https://github.com/Jip-Hop/jailmaker) for more details.

```
./install.sh
```

After that you should find yourself in your new Proxmox container shell. Run there:

```
apt install -y ifupdown2
apt install -y proxmox-ve freenas-proxmox
pveum user add admin@pam
pveum acl modify / --roles Administrator --users admin@pam
apt autoremove -y
systemctl reboot
```

```
# /mnt/data/jailmaker/templates/proxmox/config
# To use run:
#   jlmkr create <container_name> /mnt/data/jailmaker/templates/proxmox/config

```

## Network setup

![Untitled](images/network_1.png)

![Untitled](images/network_2.png)

![Untitled](images/network_3.png)
