#!/bin/bash

# Fix AppStream error
# sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
# sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.epel.cloud|g' /etc/yum.repos.d/CentOS-*
# Migrate to CentOS Stream 8
sudo dnf --disablerepo '*' --enablerepo=extras swap centos-linux-repos centos-stream-repos --allowerasing -y
sudo dnf distro-sync -y

# Install epel-release and update
sudo yum -y install epel-release 
sudo yum -y update

# Install support tools
sudo yum install -y nano vim htop yum-utils 

# Install and configure git
sudo yum install -y git
sudo git config --global pull.rebase false

# Install Java and Maven
sudo yum install -y java-1.8.0-openjdk maven

# Install docker
## Remove old version
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

## Install docker
sudo yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

## Enable and start docker
sudo systemctl enable docker
sudo systemctl start docker

# Install nginx
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
