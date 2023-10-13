
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
  default     = "code-python|/home/coder|ms-python.python"
  icon        = "/emojis/1f4bf.png"
  type        = "string"
  mutable     = false

  option {
    name  = "python"
    value = "code-python|/home/coder|ms-python.python"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg"
  }
  option {
    name  = "coq"
    value = "code-coq|/home/coq|maximedenes.vscoq"
    icon  = "https://upload.wikimedia.org/wikipedia/commons/d/d8/Coq_logo.png"
  }
  option {
    name  = "gcc"
    value = "code-gcc|/home/coder|llvm-vs-code-extensions.vscode-clangd"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/gcc/gcc-original.svg"
  }
  option {
    name  = "golang"
    value = "code-golang|/home/coder|golang.go"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/go/go-original-wordmark.svg"
  }
  option {
    name  = "haskell"
    value = "code-haskell|/home/coder|haskell.haskell"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/haskell/haskell-original.svg"
  }
  option {
    name  = "java"
    value = "code-java|/home/coder|redhat.java"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/java/java-original.svg"
  }
  option {
    name  = "node"
    value = "code-node|/home/node|eg2.vscode-npm-script"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg"
  }
  option {
    name  = "ocaml"
    value = "code-ocaml|/home/opam|ocamllabs.ocaml-platform"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ocaml/ocaml-original.svg"
  }
  option {
    name  = "perl"
    value = "code-perl|/home/coder|richterger.perl"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/perl/perl-original.svg"
  }
  option {
    name  = "ruby"
    value = "code-ruby|/home/coder|rebornix.ruby"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ruby/ruby-original.svg"
  }
  option {
    name  = "rust"
    value = "code-rust|/home/coder|rust-lang.rust"
    icon  = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/rust/rust-plain.svg"
  }
}

data "coder_parameter" "web_ide" {
  name        = "web_ide"
  description = "What VS Code Web would you like to use for your workspace?"
  default     = "none"
  icon        = "/emojis/2328.png"
  type        = "string"
  mutable     = true

  option {
    name  = "code-server"
    value = "code-server"
    icon  = "/icon/coder.svg"
  }
  option {
    name  = "vscode-server"
    value = "vscode-server"
    icon  = "/icon/code.svg"
  }
  option {
    name  = "none"
    value = "none"
    icon  = "/emojis/274c.png"
  }
}

data "coder_parameter" "web_vnc" {
  name        = "web_vnc"
  description = "What VNC Desktop Web would you like to use for your workspace?"
  default     = "none"
  icon        = "/emojis/1f5a5.png"
  type        = "string"
  mutable     = true

  option {
    name  = "KasmVNC"
    value = "kasmvnc"
    icon  = "/icon/kasmvnc.svg"
  }
  option {
    name  = "none"
    value = "none"
    icon  = "/emojis/274c.png"
  }
}

data "coder_parameter" "dotfiles_url" {
  name        = "dotfiles_url"
  description = "Dotfiles repo URL (optional). See https://dotfiles.github.io"
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
    value = data.coder_parameter.dotfiles_url.value
  }
}


# Coder resources

resource "coder_agent" "main" {
  arch  = data.coder_provisioner.me.arch
  os    = data.coder_provisioner.me.os
  dir   = split("|", data.coder_parameter.docker_image.value)[1]

  startup_script_behavior = "blocking"
  startup_script_timeout  = 180
  startup_script          = <<-EOT
#!/bin/bash

# install and start code-server
if [ "${data.coder_parameter.web_ide.value}" == "code-server" ]; then
  curl -fsSL https://code-server.dev/install.sh | sh
  code-server --extensions-dir=${split("|", data.coder_parameter.docker_image.value)[1]}/.vscode-server/extensions --install-extension ${split("|", data.coder_parameter.docker_image.value)[2]}
  code-server --port 13337 --auth none --disable-telemetry >/tmp/vscode.log 2>&1 &
fi

# install and start vscode-server
if [ "${data.coder_parameter.web_ide.value}" == "vscode-server" ]; then
  sudo apt install -y libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcairo2 libdrm2 libgbm1 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libsecret-1-0 libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 libxkbfile1 libxrandr2 xdg-utils
  curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o /tmp/code.deb
  sudo dpkg -i /tmp/code.deb && sudo apt-get install -f -y
  code --extensions-dir=${split("|", data.coder_parameter.docker_image.value)[1]}/.vscode-server/extensions --install-extension ${split("|", data.coder_parameter.docker_image.value)[2]}
  code serve-web --port 13337 --without-connection-token --disable-telemetry --accept-server-license-terms >/tmp/vscode.log 2>&1 &
fi

# install and start kasmvnc
if [ "${data.coder_parameter.web_vnc.value}" == "kasmvnc" ]; then
  sudo apt install -y libgbm1 libgl1 libxcursor1 libxfixes3 libxfont2 libxrandr2 libxshmfence1 libxtst6 ssl-cert xauth x11-xkb-utils xkb-data libswitch-perl libyaml-tiny-perl libhash-merge-simple-perl liblist-moreutils-perl libtry-tiny-perl libdatetime-timezone-perl
  sudo apt install -y dbus-x11 xvfb xfwm4 libupower-glib3 upower xfce4 xfce4-goodies xfce4-terminal xfce4-panel xfce4-session
  sudo curl -L "https://github.com/kasmtech/KasmVNC/releases/download/v1.2.0/kasmvncserver_bookworm_1.2.0_amd64.deb" -o /tmp/kasm.deb
  sudo dpkg -i /tmp/kasm.deb && apt-get install -f -y
  sudo make-ssl-cert generate-default-snakeoil --force-overwrite
  sudo sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config
  export DISPLAY=:99
  sudo Xvfb :99 >/tmp/xvfb.log 2>&1 &
  sudo dbus-launch --exit-with-session startxfce4 >/tmp/startxfce4.log 2>&1 &
  sudo kasmvncserver -disableBasicAuth >/tmp/kasmvnc.log 2>&1 &
fi

# use coder CLI to clone and install dotfiles
if [[ ! -z "${data.coder_parameter.dotfiles_url.value}" ]]; then
  coder dotfiles -y ${data.coder_parameter.dotfiles_url.value}
fi

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

resource "coder_app" "kasmvnc" {
  agent_id     = coder_agent.main.id
  slug         = "kasm"
  display_name = "VNC Desktop Web"
  icon         = "/icon/kasmvnc.svg"
  url          = "http://localhost:6901"
  share        = "owner"
  subdomain    = true

  healthcheck {
    url       = "https://localhost:6901/healthz"
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
