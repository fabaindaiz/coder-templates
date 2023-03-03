
terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 0.6.14"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
}

provider "coder" {
}


# Coder Data Sources

data "coder_workspace" "me" {
}

data "coder_provisioner" "me" {
}

#data "coder_parameter" "me" {
#  name = ""
#}


# Coder resources

resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = data.coder_provisioner.me.os

  login_before_ready     = false
  startup_script_timeout = 180
  startup_script         = <<-EOT
#!/bin/bash
set -euo pipefail

# start code-server
code-server --auth none --port 13337 &

# use coder CLI to clone and install dotfiles
coder dotfiles -y ${var.dotfiles_uri} &

  EOT

  # These environment variables allow you to make Git commits right away after creating a
  # workspace. Note that they take precedence over configuration defined in ~/.gitconfig!
  # You can remove this block if you'd prefer to configure Git manually or using
  # dotfiles. (see docs/dotfiles.md)
  env = {
    GIT_AUTHOR_NAME     = "${data.coder_workspace.me.owner}"
    GIT_COMMITTER_NAME  = "${data.coder_workspace.me.owner}"
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace.me.owner_email}"
    GIT_COMMITTER_EMAIL = "${data.coder_workspace.me.owner_email}"
  }
}

resource "coder_app" "code-server" {
  agent_id      = coder_agent.main.id
  slug          = "code"
  display_name  = "code-server"
  icon          = "${data.coder_workspace.me.access_url}/icon/code.svg"
  url           = "http://localhost:13337"
  share         = "owner"
  subdomain     = true

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}

resource "coder_metadata" "container_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = docker_container.workspace[0].id

  item {
    key   = "docker_arch"
    value = data.coder_provisioner.me.arch
  }
  item {
    key   = "docker_os"
    value = data.coder_provisioner.me.os
  }
  item {
    key   = "var_dotfiles"
    value = var.dotfiles_uri
  }
  item {
    key   = "var_image"
    value = var.docker_image
  }
  item {
    key   = "var_workdir"
    value = var.docker_workdir
  }
}


# Docker parameters

variable "docker_image" {
  description = "What Docker image would you like to use for your workspace?"
  default     = "code-base"

  validation {
    condition = contains([
      "code-base",
      "code-java",
      "code-node",
      "code-golang"
    ], var.docker_image)
    error_message = "Invalid Docker image!"
  }

  validation {
    condition     = fileexists("images/${var.docker_image}.Dockerfile")
    error_message = "Invalid Docker image. The file does not exist in the images directory."
  }
}

variable "docker_workdir" {
  description = "What Docker image would you like to use for your workspace?"
  default     = "/home/coder/"

  validation {
    condition = contains([
      "/home/coder/"
    ], var.docker_workdir)
    error_message = "Invalid Docker workdir!"
  }
}

variable "dotfiles_uri" {
  description = "Dotfiles repo URI (optional). See https://dotfiles.github.io"
  default = ""
}


# Docker resources

resource "docker_volume" "coder_volume" {
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Protect the volume from being deleted due to changes in attributes.
  lifecycle {
    ignore_changes = all
  }

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  # This field becomes outdated if the workspace is renamed but can
  # be useful for debugging or cleaning out dangling volumes.
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}

resource "docker_image" "coder_image" {
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"

  build {
    path       = "./images/"
    dockerfile = "${var.docker_image}.Dockerfile"
    tag        = ["coder-${var.docker_image}:v1.0"]
  }
  # Keep alive for other workspaces to use upon deletion
  keep_locally = true
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.coder_image.image_id
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = lower(data.coder_workspace.me.name)
  dns      = ["1.1.1.1"]
  # Use the docker gateway if the access URL is 127.0.0.1 
  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env     = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = var.docker_workdir
    volume_name    = docker_volume.coder_volume.name
    read_only      = false
  }

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
