#!/bin/bash

set -e
echo "[+] Helm install custom mysql in namespace 'test'"
helm install --name local-database --namespace test -f mysql.yaml stable/mysql
echo

echo "[+] Checking the installation"
helm list
echo

