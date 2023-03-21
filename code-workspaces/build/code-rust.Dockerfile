FROM codercom/enterprise-rust:ubuntu

ENV SHELL=/bin/bash

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension rust-lang.rust

WORKDIR /home/coder