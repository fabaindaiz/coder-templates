terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.17"
    }
  }
}


variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "workdir" {
  type        = string
  description = "The working directory of the workspace."
}

variable "extensions" {
  type        = list(string)
  description = "The list of extensions to install."
}


module "dotfiles" {
  source      = "registry.coder.com/modules/dotfiles/coder"
  agent_id    = var.agent_id
}

module "git-config" {
  source      = "registry.coder.com/modules/git-config/coder"
  agent_id    = var.agent_id
  allow_email_change = true
}

module "personalize" {
  source      = "registry.coder.com/modules/personalize/coder"
  agent_id    = var.agent_id
}


module "filebrowser" {
    source    = "registry.coder.com/modules/filebrowser/coder"
    count     = data.coder_parameter.web_file.value == "file-browser" ? 1 : 0
    agent_id  = var.agent_id
    folder    = var.workdir
}

module "kasmvnc" {
  source      = "registry.coder.com/modules/kasmvnc/coder"
  count       = data.coder_parameter.web_vnc.value == "vnc-kasmvnc" ? 1 : 0
  agent_id    = var.agent_id
  desktop_environment = "xfce"
}

module "code-cursor" {
  source      = "registry.coder.com/modules/cursor/coder"
  count       = data.coder_parameter.web_code.value == "code-cursor" ? 1 : 0
  agent_id    = var.agent_id
  folder      = var.workdir
  open_recent = true
}

module "code-server" {
  source      = "registry.coder.com/modules/code-server/coder"
  count       = data.coder_parameter.web_code.value == "code-server" ? 1 : 0
  agent_id    = var.agent_id
  folder      = var.workdir
  extensions  = var.extensions
  auto_install_extensions = true
}

module "code-vscode" {
  source      = "registry.coder.com/modules/vscode-web/coder"
  count       = data.coder_parameter.web_code.value == "code-vscode" ? 1 : 0
  agent_id    = var.agent_id
  folder      = var.workdir
  extensions  = var.extensions
  auto_install_extensions = true
  accept_license  = true
  telemetry_level = "off"
}


data "coder_parameter" "web_file" {
  type          = "string"
  name          = "web_file"
  display_name  = "Web Filebrowser"
  default       = "none"
  description   = "Would you like to use a Web Filebrowser for your workspace?"
  mutable       = true
  order         = 3
  icon          = "/icon/filebrowser.svg"

  option {
    name  = "filebrowser"
    value = "file-browser"
    icon  = "/icon/filebrowser.svg"
  }
  option {
    name  = "none"
    value = "none"
    icon  = "/emojis/274c.png"
  }
}

data "coder_parameter" "web_vnc" {
  type          = "string"
  name          = "web_vnc"
  display_name  = "Web VNC"
  default       = "none"
  description   = "Would you like to use a Web VNC for your workspace?"
  mutable       = true
  order         = 4
  icon          = "/icon/kasmvnc.svg"

  option {
    name  = "kamsvnc"
    value = "vnc-kasmvnc"
    icon  = "/icon/kasmvnc.svg"
  }
  option {
    name  = "none"
    value = "none"
    icon  = "/emojis/274c.png"
  }
}

data "coder_parameter" "web_code" {
  type          = "string"
  name          = "web_code"
  display_name  = "Web Code Editor"
  default       = "none"
  description   = "Would you like to use a Web Code Editor for your workspace?"
  mutable       = true
  order         = 5
  icon          = "/icon/code.svg"

  option {
    name  = "vscode-web"
    value = "code-vscode"
    icon  = "/icon/code.svg"
  }
  option {
    name  = "cursor"
    value = "code-cursor"
    icon  = "/icon/cursor.svg"
  }
  option {
    name  = "code-server"
    value = "code-server"
    icon  = "/icon/coder.svg"
  }
  option {
    name  = "none"
    value = "none"
    icon  = "/emojis/274c.png"
  }
}


output "web_file" {
  value = data.coder_parameter.web_file.value
}

output "web_ide" {
  value = data.coder_parameter.web_ide.value
}
