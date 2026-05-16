#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)."
  exit 1
fi

echo "--- Starting APT Maintenance ---"
#Update/Upgrade/Clear unused packages
apt update
apt full-upgrade -y
apt autoclean -y
apt autoremove -y

echo "--- Starting Snap Maintenance ---"
#Update all Snap packages
snap refresh

#Clear unused Snap packages
set -eu
snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done

echo "--- Checking for required restart ---"
if [ -f /var/run/reboot-required ]; then
    echo "***************************************************"
    echo "CRITICAL: A system restart is REQUIRED."
    echo "***************************************************"
else
    echo "No restart required. System is up to date."
fi
