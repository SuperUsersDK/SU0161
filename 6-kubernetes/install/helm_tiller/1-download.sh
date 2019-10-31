#!/bin/bash

set -e

echo "[+] Downloading"
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > install-helm.sh
echo

echo "[+] Changing permission"
chmod u+x install-helm.sh
echo 

echo "[+] Run the installer"
./install.sh
echo
