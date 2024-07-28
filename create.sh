#!/usr/bin/zsh

processTemplate() {
  while grep -q '{{.*}}' $1; do
    sed -i -r 's|(.*)\{\{(\w+)}}(.*)|echo -n "\1${\2}\3";|ge' $1
  done
}

showHelp() {
    echo "Usage: ./create.sh [options]"
    echo "Options:"
    echo "  -n, --hostname <hostname>       The hostname of the container"
    echo "  -i, --ip <containerip> The container IP address"
    echo "  -m, --mtu <mtu>                 The MTU value (1500 or 9000)"
    echo "  -j, --jlmkr "$(which jlmkr)"    The 'jlmkr' alias value"
    echo
    echo "  -h, --help                      Display this help message"
}


export MTU=9000
export GATEWAY_IP="${ip route | grep default | awk '{print $3}'}"
# Process named arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--hostname)
      export HOSTNAME="$2"
      ;;
    -i|--ip)
      export CONTAINER_IP="$2"
      ;;
    -j|--jlmkr)
      jlmkr="$(echo $2 | sed 's/jlmkr: aliased to //')"
      jlmkrPath="$(echo "$jlmkr" | sed -E "s|sudo -E '(.*)/jlmkr\.py'|\1|")"
      alias jlmkr="$jlmkr"
      ;;
    -m|--mtu)
      export MTU="$2"
      ;;
    -h|--help|*)
      showHelp
      exit 0
      ;;
    *)
      echo "\nERROR: Unknown argument '$1'\n"
      showHelp
      exit 1
      ;;
  esac
  shift
  shift
done

# Check if the required arguments are set
if [[ -z $HOSTNAME || -z $CONTAINER_IP || -z $MTU || -z $jlmkr ]]; then
  echo "\nERROR: Missing required arguments\n"
  showHelp
  exit 1
fi


containerRootPath="$jlmkrPath/jails/$HOSTNAME/rootfs/root"

# Create a new container
jlmkr create -c config $HOSTNAME

# Start the container manually to let DBUS initialize
systemd-nspawn --boot -D /mnt/data/jailmaker/jails/$HOSTNAME/rootfs -M $HOSTNAME.tmp &
sleep 5
machinectl terminate $HOSTNAME.tmp
jlmkr restart $HOSTNAME

# Copy the setup scripts to the container
cp -r container-setup "$containerRootPath/setup"
processTemplate "$containerRootPath/setup/setup1.sh"
processTemplate "$containerRootPath/setup/setup2.sh"

# Run the setup scripts
sleep 2
echo '/root/setup/setup1.sh' > "$containerRootPath/.bashrc"
jlmkr shell $HOSTNAME
sleep 2
echo '/root/setup/setup2.sh' > "$containerRootPath/.bashrc"
jlmkr shell $HOSTNAME
