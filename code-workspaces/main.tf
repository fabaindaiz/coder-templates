
terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.4.2"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.16.0"
    }
  }
}


# Admin parameters
variable "step1_arch" {
  description = "arch: What architecture is your Docker host on?"

  validation {
    condition     = contains(["amd64", "arm64", "armv7"], var.step1_arch)
    error_message = "Value must be amd64, arm64, or armv7."
  }
  sensitive = true
}


provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "coder" {
}

data "coder_workspace" "me" {
}

resource "coder_app" "code-server" {
  agent_id      = coder_agent.dev.id
  name          = "code-server"
  icon          = "https://github.com/coder/coder/tree/main/site/static/icon/code.svg"
  url           = "http://localhost:13337"
  relative_path = true
}

resource "coder_agent" "dev" {
  arch           = var.step1_arch
  os             = "linux"
  startup_script = <<EOT
#!/bin/bash
set -euo pipefail

# start code-server
code-server --auth none --port 13337 &
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

  # Prevents admin errors when the image is not found
  validation {
    condition     = fileexists("images/${var.docker_image}.Dockerfile")
    error_message = "Invalid Docker image. The file does not exist in the images directory."
  }
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}-root"
}

resource "docker_image" "coder_image" {
  name = "coder-base-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  build {
    path       = "./images/"
    dockerfile = "${var.docker_image}.Dockerfile"
    tag        = ["coder-${var.docker_image}:v0.1"]
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
  command = ["sh", "-c", replace(coder_agent.dev.init_script, "127.0.0.1", "host.docker.internal")]
  env     = ["CODER_AGENT_TOKEN=${coder_agent.dev.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/coder/"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }
}