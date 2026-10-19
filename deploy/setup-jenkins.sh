#!/bin/bash
# Jenkins server (Ubuntu 22.04/24.04) par run karo: sudo bash setup-jenkins.sh
set -e
apt-get update -y
apt-get install -y ca-certificates curl gnupg openjdk-17-jre git
# Docker
curl -fsSL https://get.docker.com | sh
# Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key -o /usr/share/keyrings/jenkins-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update -y && apt-get install -y jenkins
usermod -aG docker jenkins
systemctl enable --now jenkins
systemctl restart jenkins
echo "Jenkins admin password:"; cat /var/lib/jenkins/secrets/initialAdminPassword
