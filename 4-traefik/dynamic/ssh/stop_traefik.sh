#!/bin/bash

echo "[+] Stopping and removing dynamic traefik"
docker container rm -f traefik
