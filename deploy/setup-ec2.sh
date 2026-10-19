#!/bin/bash
# App EC2 (Ubuntu) par run karo: sudo bash setup-ec2.sh
set -e
apt-get update -y
curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu
systemctl enable --now docker
mkdir -p /home/ubuntu/nexvion && chown ubuntu:ubuntu /home/ubuntu/nexvion
echo "EC2 ready. Logout/login once so docker group apply ho jaye."
