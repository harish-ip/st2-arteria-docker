#!/bin/bash -x
# Installs the AWS CodeDeploy agent

REGION=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone/ | sed 's/[a-z]$//')

sudo apt-get update && sudo apt-get install -y ruby
cd /home/ubuntu
wget https://aws-codedeploy-$REGION.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
