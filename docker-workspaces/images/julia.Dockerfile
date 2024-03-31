FROM julia:latest

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
        ssl-cert \
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

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
        --create-home \
        --shell=/bin/bash \
        --groups=ssl-cert \
        --uid=1000 \
        --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER coder

ENV PATH=/usr/local/julia/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Run custom commands

WORKDIR /home/coder