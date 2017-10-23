FROM python:2.7

# install packages
RUN apt-get update
RUN apt-get install -y \
    less \
    openssh-server \
    rsync \
    sudo \
    vim

RUN printf "alias ll='ls --color=auto -hal'" > /root/.bashrc

# add and configure the st2 user (stanley)
RUN useradd -ms /bin/bash stanley
# RUN echo -e "stanley" | (passwd --stdin stanley)
RUN echo 'stanley:stanley' | chpasswd

RUN mkdir -p /home/stanley/.ssh \
    && chmod 0700 /home/stanley/.ssh \
    && printf "Host bcl2fastq_ws\n  IdentityFile /home/stanley/.ssh/stanley_rsa\n" > /home/stanley/.ssh/config \
    && printf "alias ll='ls --color=auto -hal'" > /home/stanley/.bashrc \
    && chown -R stanley:stanley /home/stanley

WORKDIR /opt

# create runfolder resources
RUN mkdir monitored-folder \
    && git clone  https://github.com/roryk/tiny-test-data.git \
    && cp -r tiny-test-data/flowcell /opt/monitored-folder/run1 \
    && cp -r tiny-test-data/flowcell /opt/monitored-folder/run2 \
    && cp -r tiny-test-data/flowcell /opt/monitored-folder/run3

# setup arteria-runfolder service
RUN git clone https://github.com/arteria-project/arteria-runfolder.git
WORKDIR arteria-runfolder
COPY app.config config/
RUN pip install -r requirements/dev .

WORKDIR /opt
COPY service-start-wrapper.sh service-start-wrapper.sh

EXPOSE 80
CMD bash service-start-wrapper.sh 80
#ENTRYPOINT runfolder-ws --port 80 --configroot config/

# NOTE: requires proper ssh setup (key file for user stanley from stackstorm container) in order to support st2 remote actions
