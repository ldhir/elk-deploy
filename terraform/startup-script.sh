#!/bin/bash
# Runs once on first boot (as root). Gets the VM ready for the ELK stack.
set -e

# Docker + compose plugin
curl -fsSL https://get.docker.com | sh
# let the default 'ubuntu' user run docker without sudo
usermod -aG docker ubuntu || true

# Elasticsearch refuses to start without this kernel setting
sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' > /etc/sysctl.d/99-elastic.conf

# Handy: clone the repo so the docker/ stack is already on the box
apt-get update -y && apt-get install -y git
cd /home/ubuntu
git clone https://github.com/ldhir/elk-deploy.git || true
chown -R ubuntu:ubuntu /home/ubuntu/elk-deploy
