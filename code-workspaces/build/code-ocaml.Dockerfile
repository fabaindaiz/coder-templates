FROM ocaml/opam:latest

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
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
        nasm \
        clang
# && rm -rf /var/lib/apt/lists/*

# Make typing unicode characters in the terminal work.
ENV LANG en_US.UTF-8

# Add a user `coder` so that you're not developing as the `root` user
RUN usermod opam \
        --home=/home/opam \
        --shell=/bin/bash \
        --groups=opam,docker \
        --uid=1000 && \
    echo "opam ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER opam

# Run user commands

RUN opam init -y
RUN opam update
RUN eval `opam env`

#RUN opam switch create 5.0.0
#RUN eval `opam env`

RUN opam install --unlock-base --yes \
    dune \
    utop \
    merlin \
    containers \
    alcotest \
    ocaml-lsp-server

#RUN dune build --watch --terminal-persistence=clear-on-rebuild

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension ocamllabs.ocaml-platform

WORKDIR /home/coder