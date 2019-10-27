#!/bin/bash

# stop script on any failure
set -e

echo "[+] Install master"
# must run as root
[ "$UID" -ne 0 ] && echo "This script must run as root" && exit 1

echo "[+] kubeadm init"
kubeadm init --pod-network-cidr=10.0.1.0/24 --apiserver-advertise-address=10.0.0.10
echo

echo "[+] Setting hostname"
hostnamectl set-hostname kubemaster
