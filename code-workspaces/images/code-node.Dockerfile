FROM codercom/enterprise-node:ubuntu

ENV SHELL=/bin/bash

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension eg2.vscode-npm-script

WORKDIR /home/coder