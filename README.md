# docker-compose setup for UMCCR's StackStorm / Arteria framework

[![Build Status](https://travis-ci.org/umccr/st2-arteria-docker.svg?branch=master)](https://travis-ci.org/umccr/st2-arteria-docker)

This will set up a docker container network that can be used for local development and testing. Containers are pre-configured and hardcoded to a small set of narrow use-cases. Additional configuration is needed (see below) in order to run the simple UMCCR workflow (copy runfolder and start bcl2fastq conversion).


## Quickstart
To set up all the containers run
`docker-compose up --build -d`

This will set up the default StackStorm containers (stackstorm, postgres, redis, rabbitmq, mongo) and the following additions:
- bcl2fastq_ws : container running the arteria-bcl2fastq micro service
- runfolder_ws : container running the arteria-runfolder micro service
- nginx : container serving a simple HTML file and proxy to query the runfolder and bcl2fastq job status.


You can run commands on the containers via docker-compose:
- `docker-compose exec <container> <command>`

Or via opening a shell in the container:
- `docker exec -it <container> /bin/bash`

The StackStorm web interface should be available on `https://localhost` on the docker host machine.
There should also be a web page showing the available runfolders and bcl2fastq job states at `http://localhost:7000/runfolder-status.html`.

## testing
```
st2-run-pack-tests -p /opt/stackstorm/packs/arteria
```

## Getting started with setup for UMCCR test workflow

On docker host:
```
git clone https://github.com/umccr/st2-arteria-docker.git
cd st2-arteria-docker
docker-compose up -d --build
docker exec -it stackstorm /bin/bash
```

On stackstorm container:
```
# install some linux tools useful for manual work (change/add to your preference)
apt-get update
apt-get install -y vim less

# create ssh setup
su stanley
echo "
Host runfolder_ws
  IdentityFile ~/.ssh/stanley_rsa
  ForwardAgent yes

Host bcl2fastq_ws
  IdentityFile ~/.ssh/stanley_rsa
  ForwardAgent yes
" >> ~/.ssh/config
ssh-copy-id -i ~/.ssh/stanley_rsa.pub runfolder_ws
ssh-copy-id -i ~/.ssh/stanley_rsa.pub bcl2fastq_ws
scp ~/.ssh/stanley_rsa runfolder_ws:/home/stanley/.ssh/
exit
# may beed to ssh into runfolder_ws and bcl2fastq_ws manually first to add servers to known_hosts

# Then install and configure the pack and workflow
st2 pack install https://github.com/umccr/arteria-packs.git
cp /opt/stackstorm/packs/arteria/arteria.yaml.example /opt/stackstorm/configs/arteria.yaml
st2ctl reload --register-configs
st2 action enable arteria.umccr_test
st2 rule enable arteria.umccr_workflow_test
st2 sensor enable arteria.IncomingSensor
st2 sensor disable arteria.IncomingSensor

# To monitor the tasks
st2 execution list
st2 execution get <task ID>
```

## Deployment (WIP)

Unfortunately Amazon [does not support version 3 docker compose syntax](https://twitter.com/braincode/status/928109053074706432),
so we cannot use Amazon ECS out of the box:

    $ ecs-cli configure --region ap-southeast-2 --access-key <ACCESS_KEY> --secret-key <SECRET_KEY> --cluster arteria
	INFO[0000] Saved ECS CLI configuration for cluster (arteria)

    $ ecs-cli compose up

Instead we'll try with kubernetes hosted on EC2 for starters (back to kops and self-managed clustering).


## ToDo:

- move from playground arteria pack to stable / production pack
- add tests (follow StackStorm recommendations / requirements)
- automate pack installation and configuration
- remove hardcoded config where possible / useful
- evaluate and use more Arteria components
