#!/bin/sh

apt-get install -y docker.io
gpasswd -a ubuntu docker
newgrp docker
