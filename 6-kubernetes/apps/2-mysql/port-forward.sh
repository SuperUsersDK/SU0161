#!/bin/bash

echo "[+] Setting up port-forwarding"
kubectl port-forward svc/local-database-mysql 3306 -n test
