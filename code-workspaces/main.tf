
terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
    }
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
}

provider "coder" {
}


data "coder_workspace" "me" {
}

data "coder_provisioner" "me" {
}


# Coder parameters

data "coder_parameter" "docker_image" {
  name        = "docker_image"
  description = "What Docker image would you like to use for your workspace?"
  default     = "code-python|/home/coder"
  icon        = "/emojis/1f4bf.png"
  type        = "string"
  mutable     = false

  option {
    name  = "python"
    value = "code-python|/home/coder"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg"
  }
  option {
    name  = "coq"
    value = "code-coq|/home/coq"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vscode/vscode-original.svg"
  }
  option {
    name  = "gcc"
    value = "code-gcc|/home/coder"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/gcc/gcc-original.svg"
  }
  option {
    name  = "golang"
    value = "code-golang|/home/coder"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/go/go-original-wordmark.svg"
  }
  option {
    name  = "haskell"
    value = "code-haskell|/home/coder"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/haskell/haskell-original.svg"
  }
  option {
    name  = "java"
    value = "code-java|/home/coder"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/java/java-original.svg"
  }
  option {
    name  = "node"
    value = "code-node|/home/node"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg"
  }
  option {
    name  = "ocaml"
    value = "code-ocaml|/home/opam"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ocaml/ocaml-original.svg"
  }
  option {
    name  = "perl"
    value = "code-perl|/home/coder"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/perl/perl-original.svg"
  }
  option {
    name  = "ruby"
    value = "code-ruby|/home/coder"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ruby/ruby-original.svg"
  }
  option {
    name  = "rust"
    value = "code-rust|/home/coder"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/rust/rust-plain.svg"
  }
}

data "coder_parameter" "dotfiles_uri" {
  name        = "dotfiles_uri"
  description = "Dotfiles repo URI (optional). See https://dotfiles.github.io"
  default     = ""
  icon        = "/emojis/1f4c4.png"
  type        = "string"
  mutable     = true
}

resource "coder_metadata" "container_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = docker_container.workspace[0].id

  item {
    key   = "var_image"
    value = split("|", data.coder_parameter.docker_image.value)[0]
  }
  item {
    key   = "var_workdir"
    value = split("|", data.coder_parameter.docker_image.value)[1]
  }
  item {
    key   = "var_dotfiles"
    value = data.coder_parameter.dotfiles_uri.value
  }
}


# Coder resources

resource "coder_agent" "main" {
  arch  = data.coder_provisioner.me.arch
  os    = data.coder_provisioner.me.os
  dir   = split("|", data.coder_parameter.docker_image.value)[1]

  startup_script_behavior = "non-blocking"
  startup_script_timeout  = 60
  startup_script          = <<-EOT
#!/bin/bash
set -e

# start code-server
code-server --auth none --port 13337 &

# use coder CLI to clone and install dotfiles
if [ "${data.coder_parameter.dotfiles_uri.value}" != "" ]; then
coder dotfiles -y ${data.coder_parameter.dotfiles_uri.value}; fi

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

  display_apps {
    vscode          = true
    vscode_insiders = false
    web_terminal    = true
    ssh_helper      = true
  }

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }
}

resource "coder_app" "code-server" {
  agent_id      = coder_agent.main.id
  slug          = "code"
  display_name  = "VS Code Web"
  icon          = "/icon/code.svg"
  url           = "http://localhost:13337"
  share         = "owner"
  subdomain     = true

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
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
    context    = "./build/"
    dockerfile = "${split("|", data.coder_parameter.docker_image.value)[0]}.Dockerfile"
    tag        = ["coder-${split("|", data.coder_parameter.docker_image.value)[0]}"]
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
    container_path = split("|", data.coder_parameter.docker_image.value)[1]
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
