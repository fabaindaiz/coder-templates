FROM eclipse-temurin:latest

SHELL ["/bin/bash", "-c"]

USER root

# Upgrade apt repository packages
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get upgrade --yes && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes apt-transport-https ca-certificates curl gpg

RUN install -m 0755 -d /etc/apt/keyrings

# Install the Docker apt repository
RUN curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu focal stable" > /etc/apt/sources.list.d/docker.list

# Install the VSCode apt repository
#RUN curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor --yes -o /etc/apt/keyrings/packages.microsoft.gpg
#RUN chmod a+r /etc/apt/keyrings/packages.microsoft.gpg
#RUN echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list

# Install baseline packages
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
        bash \
        build-essential \
        ca-certificates \
        containerd.io \
        curl \
        docker-ce \
        docker-ce-cli \
        docker-compose-plugin \
        git \
        htop \
        locales \
        man \
        software-properties-common \
        sudo \
        systemd \
        systemd-sysv \
        vim \
        wget \
        zip \
        rsync

# Install custom packages
#RUN apt-get update && \
#    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
# && rm -rf /var/lib/apt/lists/*

# Make typing unicode characters in the terminal work.
ENV LANG en_US.UTF-8

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
      --create-home \
      --shell=/bin/bash \
      --groups=docker \
      --uid=1000 \
      --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER coder

# Run custom commands

# install code-server
#curl -fsSL https://code-server.dev/install.sh | sh
#RUN code-server --install-extension redhat.java

WORKDIR /home/coder