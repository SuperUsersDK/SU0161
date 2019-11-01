#!/bin/bash

echo "[+] Stopping container sshserver1"
docker container rm -f sshserver1

echo "[+] Stopping container sshserver2"
docker container rm -f sshserver2
