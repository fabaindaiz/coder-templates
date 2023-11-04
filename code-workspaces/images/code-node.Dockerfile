FROM node:latest

SHELL ["/bin/bash", "-c"]

USER root

# Upgrade apt repository packages & Install baseline packages
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get upgrade --yes && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        gpg \
        htop \
        locales \
        man \
        nano \
        software-properties-common \
        sudo \
        vim \
        wget \
        zip \
        rsync

# Install custom packages
#RUN apt-get update && \
#    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
#    && rm -rf /var/lib/apt/lists/*

# Make typing unicode characters in the terminal work.
ENV LANG en_US.UTF-8

# Add a user `node` so that you're not developing as the `root` user
RUN usermod node \
        --home=/home/node \
        --shell=/bin/bash \
        --groups=node,ssl-cert \
        --uid=1000 && \
    echo "node ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER node

# Run custom commands

WORKDIR /home/node