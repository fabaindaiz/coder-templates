---
name: JetBrains Projector containers for Coder
description: Build images and run JetBrains workspaces on the Docker host with no image registry required
tags: [local, docker]
---

# projector-container

Provison JetBrains Projector containers with Coder.

![pyCharm in Coder](https://raw.githubusercontent.com/bpmct/coder-templates/main/screenshots/projector-pycharm.png)

This example bundles Dockerfiles with the Coder template, allowing the Docker host to build images itself instead of relying on an external registry.

For large use cases, we recommend building images using CI/CD pipelines and registries instead of at workspace runtime. However, this example is practical for tinkering and iterating on Dockerfiles.

## Requirements

Docker running on the Coder server.

## Getting started

Run `coder templates create` from the current directory and select this template. Follow the instructions that appear.

## Extending this template

See the [kreuzwerker/docker](https://registry.terraform.io/providers/kreuzwerker/docker) Terraform provider documentation to
add the following features to your Coder template:

- SSH/TCP docker host
- Build args
- Volume mounts
- Custom container spec
- More

We also welcome all contributions!
