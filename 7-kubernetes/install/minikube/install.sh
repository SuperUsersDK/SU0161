#!/bin/bash

set -e
echo "[+] Downloading latest minikube"
/usr/bin/curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
echo

echo "[+] Change permission and move to /usr/local/bin"
/bin/chmod +x minikube
/usr/bin/sudo mv minikube /usr/local/bin
echo

echo "[+] Deleting previous config if existing"
set +e
/usr/bin/sudo /bin/rm -rf $HOME/.kube
/usr/bin/sudo /bin/rm -rf /etc/rancher
set -e

echo "[+] Start minikub"
/usr/local/bin/minikube start
echo

echo "[+] Download latest kubectl"
/usr/bin/curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | 
     /usr/bin/sudo /usr/bin/tee -a /etc/apt/sources.list.d/kubernetes.list >/dev/null
/usr/bin/sudo /usr/bin/apt-get update
/usr/bin/sudo /usr/bin/apt-get install -y kubectl
echo 

echo "[+] Testing installation"
/usr/local/bin/kubectl cluster-info

echo "[+] Setting bash completion"
/usr/local/bin/kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl >/dev/null
source /etc/bash_completion.d/kubectl
