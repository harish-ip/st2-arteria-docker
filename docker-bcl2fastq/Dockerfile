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
    && printf "alias ll='ls --color=auto -hal'" > /home/stanley/.bashrc \
    && chown -R stanley:stanley /home/stanley

COPY bcl2fastq.mock /opt/bcl2fastq/bcl2fastq
RUN chmod 755 /opt/bcl2fastq/bcl2fastq
RUN ln -s /opt/bcl2fastq/bcl2fastq /usr/bin/bcl2fastq

WORKDIR /opt

# create runfolder resources
RUN mkdir runfolder \
    && chown -R stanley:stanley ./runfolder \
    && mkdir runfolder_output \
    && chown -R stanley:stanley ./runfolder_output


# setup arteria-bcl2fastq service
RUN mkdir bcl2fastq_logs \
    && chown -R stanley:stanley ./bcl2fastq_logs
RUN git clone https://github.com/arteria-project/arteria-bcl2fastq.git
WORKDIR arteria-bcl2fastq
COPY app.config config/
RUN pip install -r requirements/dev .

WORKDIR /opt
COPY service-start-wrapper.sh service-start-wrapper.sh

EXPOSE 80
CMD bash service-start-wrapper.sh 80
#ENTRYPOINT bcl2fastq-ws --port 80 --config config/

# NOTE: requires proper ssh setup (key file for user stanley from stackstorm container) in order to support st2 remote actions
