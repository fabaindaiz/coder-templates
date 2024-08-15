FROM ocaml/opam:latest

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
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
        nasm \
        clang
#    && rm -rf /var/lib/apt/lists/*

# Make typing unicode characters in the terminal work.
ENV LANG en_US.UTF-8

# Add a user `opam` so that you're not developing as the `root` user
RUN usermod opam \
        --home=/home/opam \
        --shell=/bin/bash \
        --groups=opam,ssl-cert \
        --uid=1000 && \
    echo "opam ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER opam

# Run custom commands
RUN opam-2.2 init -y && \
    opam-2.2 update && \
    eval `opam-2.2 env`
    
RUN opam-2.2 install --yes \
    ocaml-lsp-server \
    dune \
    utop \
    alcotest \
    containers \
    merlin \
    ocamlformat-rpc

WORKDIR /home/opam