FROM codercom/enterprise-base:ubuntu

ENV SHELL=/bin/bash

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension ms-python.python

WORKDIR /home/coder