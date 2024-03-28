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
  source      = "../git-config/"
  agent_id    = var.agent_id
  allow_email_change = true
}

module "personalize" {
  source      = "registry.coder.com/modules/personalize/coder"
  agent_id    = var.agent_id
}


module "filebrowser" {
    source    = "registry.coder.com/modules/filebrowser/coder"
    agent_id  = var.agent_id
    count     = data.coder_parameter.web_file.value == "filebrowser" ? 1 : 0
}

module "code-server" {
  source      = "registry.coder.com/modules/code-server/coder"
  agent_id    = var.agent_id
  count       = data.coder_parameter.web_ide.value == "code-server" ? 1 : 0
  folder      = var.workdir
  extensions  = var.extensions
}

module "vscode-web" {
  source      = "registry.coder.com/modules/vscode-web/coder"
  agent_id    = var.agent_id
  count       = data.coder_parameter.web_ide.value == "vscode-web" ? 1 : 0
  folder      = var.workdir
  extensions  = var.extensions
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
  icon          = "https://upload.wikimedia.org/wikipedia/commons/5/59/OneDrive_Folder_Icon.svg"

  option {
    name  = "filebrowser"
    value = "filebrowser"
    icon  = "https://raw.githubusercontent.com/filebrowser/logo/master/icon_raw.svg"
  }
  option {
    name  = "none"
    value = "none"
    icon  = "/emojis/274c.png"
  }
}

data "coder_parameter" "web_ide" {
  type          = "string"
  name          = "web_ide"
  display_name  = "Web IDE"
  default       = "none"
  description   = "Would you like to use a Web IDE for your workspace?"
  mutable       = true
  order         = 5
  icon          = "https://upload.wikimedia.org/wikipedia/commons/f/f5/.exe_OneDrive_icon.svg"

  option {
    name  = "vscode-web"
    value = "vscode-web"
    icon  = "/icon/code.svg"
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
