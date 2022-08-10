FROM ocaml/opam

ENV SHELL=/bin/bash

USER root

RUN apt update && apt-get install -y \
  nasm \
  clang
# && rm -rf /var/lib/apt/lists/*

USER opam

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension ocamllabs.ocaml-platform

# opam init -a
RUN opam init -y
RUN opam update
RUN eval `opam env`

# opam switch list-available
RUN opam switch create 4.14.0
RUN eval `opam env`

RUN opam install -y \
  dune \
  utop \
  merlin \
  containers \
  alcotest \
  ocaml-lsp-server

#RUN dune build --watch --terminal-persistence=clear-on-rebuild