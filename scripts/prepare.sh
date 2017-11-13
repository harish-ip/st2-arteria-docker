#!/bin/sh

apt-get install docker.io
gpasswd -a ubuntu docker
newgrp docker
