#!/usr/bin/env sh

if [ "$(id -u)" -ne 0 ]; then
  echo Must be run as root
  exit 1
fi

# Add Docker's official GPG key:
apt update
apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt remove docker docker.io docker-compose docker-doc containerd runc podman-docker
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
