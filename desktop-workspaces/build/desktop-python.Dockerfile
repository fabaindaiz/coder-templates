FROM kasmweb/desktop:1.12.0

USER root

# Configure kasmvnc
COPY kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh
RUN cp -r /home/kasm-user /tmp/kasm-user
RUN apt-get update && apt-get install sudo
RUN echo "kasm-user ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd
RUN DEBIAN_FRONTEND=noninteractive make-ssl-cert generate-default-snakeoil --force-overwrite
RUN adduser kasm-user ssl-cert

USER 1000

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension ms-python.python

WORKDIR /home/kasm-user