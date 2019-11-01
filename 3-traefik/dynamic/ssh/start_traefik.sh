#!/bin/bash

echo "[+] Starting dynamic traefik"
docker container run --name traefk \
   -d -v $PWD/traefik.toml:/etc/traefik/traefik.toml \
   -v /var/run/docker.sock:/var/run/docker.sock:ro \
   -p 80:80 \
   -p 443:443 \
   traefik:latest

