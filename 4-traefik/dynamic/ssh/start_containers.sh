#!/bin/bash

echo "[+] Starting container sshserver1"
docker run -d -P \
  --name sshserver1 \
  --label traefik.frontend.rule=Host:sshserver1 \
  rastasheep/ubuntu-sshd:14.04
docker port sshserver1 22

echo "[+] Starting container sshserver2"
docker run -d -P \
  --name sshserver2 \
  --label traefik.frontend.rule=Host:sshserver2 \
  rastasheep/ubuntu-sshd:14.04
docker port sshserver2 22
