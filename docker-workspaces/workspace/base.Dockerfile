# syntax=docker/dockerfile:1

# Single stage build
FROM ${IMAGE}:latest

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8

USER root

# From https://stackoverflow.com/questions/66808788/docker-can-you-cache-apt-get-package-installs#72851168
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
 && apt-get update \
 && apt-get -y --no-install-recommends install \
      bash \
      curl \
      git \
      locales \
      man \
      sudo \
      vim

ARG USER=coder
RUN if [ id "${USER}" &>/dev/null ]; then \
      usermod ${USER} \
        --shell=/bin/bash \
        --uid=1000; \
    else \
      useradd ${USER} \
        --create-home \
        --user-group \
        --shell=/bin/bash \
        --uid=1000; \
    fi \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USER} \
 && chmod 0440 /etc/sudoers.d/${USER}

USER ${USER}
WORKDIR /home/${USER}