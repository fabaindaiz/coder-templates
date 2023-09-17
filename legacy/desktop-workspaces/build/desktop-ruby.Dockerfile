FROM kasmweb/desktop:1.12.0

USER root

# Configure kasmvnc
ENV STARTUPDIR /dockerstartup
COPY kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY vnc_startup.sh $STARTUPDIR/vnc_startup.sh
COPY kasm_default_profile.sh $STARTUPDIR/kasm_default_profile.sh
RUN chmod -R +x $STARTUPDIR
RUN chmod -R 755 $STARTUPDIR
RUN cp -r /home/kasm-user /tmp/kasm-user
RUN apt-get update && apt-get install -y sudo
RUN echo "kasm-user ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd
RUN DEBIAN_FRONTEND=noninteractive make-ssl-cert generate-default-snakeoil --force-overwrite
RUN adduser kasm-user ssl-cert

# Install baseline packages
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
      bash \
      curl \
      htop \
      locales \
      man \
      python3 \
      python3-pip \
      software-properties-common \
      sudo \
      vim \
      wget \
      rsync

# Install OpenSSL library
RUN DEBIAN_FRONTEND="noninteractive" apt-get update -y && \
    apt-get install -y libssl-dev

# Install Ruby from source
COPY ./install-ruby.sh /tmp
RUN chmod +x /tmp/install-ruby.sh && /tmp/install-ruby.sh

USER 1000

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension rebornix.ruby

WORKDIR /home/kasm-user