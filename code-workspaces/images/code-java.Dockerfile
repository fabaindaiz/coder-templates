FROM codercom/enterprise-java:ubuntu

ENV SHELL=/bin/bash

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
