#!/bin/sh

apt-get install -y docker.io
gpasswd -a ubuntu docker
newgrp docker
#chown -R ubuntu:ubuntu /srv/arteria
