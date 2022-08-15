FROM coqorg/coq

ENV SHELL=/bin/bash

USER root

RUN apt update
# && apt-get install -y 
# && rm -rf /var/lib/apt/lists/*

USER coq

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension maximedenes.vscoq

WORKDIR /home/coq