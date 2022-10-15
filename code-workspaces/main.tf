
terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.5.2"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.22.0"
    }
  }
}


provider "docker" {
  host = data.coder_workspace.me.arch == "linux" ? "unix:///var/run/docker.sock" : "npipe:////.//pipe//docker_engine"
}

provider "coder" {
}


data "coder_workspace" "me" {
}

data "coder_provisioner" "me" {
}

data "coder_parameter" "coder_share" {
  description = "What Docker image would you like to use for your workspace?"
  default     = "owner"
  mutable     = true

  option {
    name        = "owner"
    description = "Disables sharing on the app, so only the workspace owner can access it"
    value       = "owner"
  }
  option {
    name        = "authenticated"
    description = "Shares the app with all authenticated users"
    value       = "authenticated"
  }
  option {
    name        = "public"
    description = "Shares it with any user, including unauthenticated users"
    value       = "public"
  }
}

variable "docker_arch" {
  description = "What architecture is your Docker host on?"
  default     = data.coder_provisioner.me.arch

  validation {
    condition     = contains(["amd64", "arm64", "armv7"], var.docker_arch)
    error_message = "Value must be amd64, arm64, or armv7."
  }
  sensitive = true
}

variable "docker_os" {
  description = "What operating system is your Coder host on?"
  default     = data.coder_provisioner.me.os

  validation {
    condition     = contains(["linux", "windows"], var.docker_os)
    error_message = "Value must be Linux, or Windows."
  }
  sensitive = true
}



resource "coder_app" "code-server" {
  agent_id  = coder_agent.main.id
  name      = "code-server"
  icon      = "${data.coder_workspace.me.access_url}/icon/code.svg"
  url       = "http://localhost:13337"
  share     = data.coder_parameter.coder_share.value
  subdomain = false
  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}

resource "coder_agent" "main" {
  arch           = var.docker_arch
  os             = var.docker_os
  startup_script = <<EOT
#!/bin/bash
set -euo pipefail

# start code-server
code-server --auth none --port 13337 &

# use coder CLI to clone and install dotfiles
coder dotfiles -y ${var.dotfiles_uri}
  EOT
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


resource "docker_volume" "coder_volume" {
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
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
  image = docker_image.coder_image.latest
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = lower(data.coder_workspace.me.name)
  dns      = ["1.1.1.1"]
  # Use the docker gateway if the access URL is 127.0.0.1 
  command = ["sh", "-c", replace(coder_agent.main.init_script, "127.0.0.1", "host.docker.internal")]
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
}

resource "coder_metadata" "container_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = docker_container.workspace[0].id

  item {
    key   = "image"
    value = var.docker_image
  }
  item {
    key = "workdir"
    value = var.docker_workdir
  }
  item {
    key = "dotfiles"
    value = var.dotfiles_uri
  }
}
