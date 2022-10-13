
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


# Admin parameters

variable "docker_arch" {
  description = "What architecture is your Docker host on?"

  validation {
    condition     = contains(["amd64", "arm64", "armv7"], var.docker_arch)
    error_message = "Value must be amd64, arm64, or armv7."
  }
  sensitive = true
}

variable "docker_os" {
  description = "What operating system is your Coder host on?"

  validation {
    condition     = contains(["linux", "windows"], var.docker_os)
    error_message = "Value must be linux, or windows."
  }
  sensitive = true
}


provider "docker" {
  host = var.docker_os == "linux" ? "unix:///var/run/docker.sock" : "npipe:////.//pipe//docker_engine"
}

provider "coder" {
}

data "coder_workspace" "me" {
}


resource "coder_app" "novnc" {
  agent_id      = coder_agent.main.id
  name          = "noVNC Desktop"
  icon          = "${data.coder_workspace.me.access_url}/icon/novnc-icon.svg"
  url           = "http://localhost:6081"
  relative_path = true
}

resource "coder_app" "code-server" {
  agent_id      = coder_agent.main.id
  name          = "code-server"
  icon          = "${data.coder_workspace.me.access_url}/icon/code.svg"
  url           = "http://localhost:13337"
  relative_path = true
}

resource "coder_agent" "main" {
  arch           = var.docker_arch
  os             = var.docker_os
  startup_script = <<EOT
#!/bin/bash
set -euo pipefail

# start code-server
code-server --auth none --port 13337 &

# start VNC
echo "Creating desktop..."
mkdir -p "$XFCE_DEST_DIR"
cp -rT "$XFCE_BASE_DIR" "$XFCE_DEST_DIR"

# Skip default shell config prompt.
cp /etc/zsh/newuser.zshrc.recommended $HOME/.zshrc

echo "Initializing Supervisor..."
nohup supervisord

# use coder CLI to clone and install dotfiles
coder dotfiles -y ${var.dotfiles_uri}
  EOT
}


# Docker parameters

variable "docker_image" {
  description = "What Docker image would you like to use for your workspace?"
  default     = "desktop-base"

  validation {
    condition = contains([
      "desktop-base",
      "desktop-java",
      "desktop-node",
      "desktop-golang"
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


resource "docker_volume" "home_volume" {
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
    volume_name    = docker_volume.home_volume.name
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
