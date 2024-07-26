#!/bin/bash

config=/tmp/$HOSTNAME.config
cp config-template $config
while grep -q '{{.*}}' $config; do
  sed -i -r 's|(.*)\{\{(\w+)}}(.*)|echo -n "\1${\2}\3";|ge' $config
done
jlmkr create $HOSTNAME $config
systemd-nspawn --boot -D /mnt/data/jailmaker/jails/$HOSTNAME/rootfs -M $HOSTNAME.tmp &
sleep 2
machinectl terminate $HOSTNAME.tmp
jlmkr restart $HOSTNAME
jlmkr shell $HOSTNAME

