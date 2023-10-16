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
        --groups=opam \
        --uid=1000 && \
    echo "opam ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER opam

# Run user commands

RUN opam init -y && \
    opam update && \
    eval `opam env`

#RUN opam switch create 5.0.0 && \
#    eval `opam env`

RUN opam install --unlock-base --yes \
        dune \
        utop \
        merlin \
        containers \
        alcotest \
        ocaml-lsp-server

WORKDIR /home/opam