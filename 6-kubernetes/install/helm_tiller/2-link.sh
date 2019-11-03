#!/bin/bash

set -e
echo "[+] Create tiller service account"
kubectl -n kube-system create serviceaccount tiller
echo

echo "[+] Create cluster role binding for tiller"
kubectl create clusterrolebinding tiller \
  --clusterrole cluster-admin \
  --serviceaccount=kube-system:tiller
echo

echo "[+] Initialize tiller"
helm init --service-account tiller
echo
