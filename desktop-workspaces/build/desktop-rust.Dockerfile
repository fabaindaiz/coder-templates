FROM kasmweb/desktop:1.12.0

USER root

# Configure kasmvnc
COPY kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY vnc_startup.sh /dockerstartup/vnc_startup.sh
COPY kasm_default_profile.sh /dockerstartup/kasm_default_profile.sh
RUN cp -r /home/kasm-user /tmp/kasm-user
RUN apt-get update && apt-get install sudo
RUN echo "kasm-user ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd
RUN DEBIAN_FRONTEND=noninteractive make-ssl-cert generate-default-snakeoil --force-overwrite
RUN adduser kasm-user ssl-cert

# Set environment variables 
ENV RUSTUP_HOME=/opt/rustup
ENV CARGO_HOME=/opt/cargo
ENV PATH=/opt/cargo/bin:$PATH

# Install Rust
COPY rustup.sh /tmp/rustup.sh
RUN /tmp/rustup.sh -y \
                   --no-modify-path \
                   --profile minimal \
                   --default-toolchain stable \
                   --default-host x86_64-unknown-linux-gnu && \
    rm -f /tmp/rustup.sh && \
    chmod -R a+w ${RUSTUP_HOME} ${CARGO_HOME}

# Validate that cargo and rustc are available
RUN cargo --version && rustc --version

USER 1000

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension rust-lang.rust

WORKDIR /home/kasm-user