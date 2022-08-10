FROM codercom/enterprise-base:ubuntu

ENV SHELL=/bin/bash

# install code-server
#RUN curl -fsSL https://code-server.dev/install.sh | sh

USER root

RUN apt-get -y install opam nasm clang wget

RUN wget https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v1.70.0/openvscode-server-v1.70.0-linux-arm64.tar.gz
RUN tar -xzf openvscode-server-v1.70.0-linux-arm64.tar.gz
RUN chown -R coder:coder openvscode-server-v1.70.0-linux-arm64

USER coder

# opam init -a
RUN opam init -y
RUN opam update
RUN eval `opam env`

# opam switch list-available
RUN opam switch create 4.14.0
RUN eval `opam env`

RUN opam install dune utop merlin containers alcotest ocaml-lsp-server -y
RUN dune build --watch --terminal-persistence=clear-on-rebuild