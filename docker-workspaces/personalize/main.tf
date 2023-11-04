terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 0.12"
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
  source      = "../modules/dotfiles/"
  agent_id    = var.agent_id
}

module "git-config" {
  source      = "../modules/git-config"
  agent_id    = var.agent_id
  allow_email_change = true
}

module "personalize" {
  source      = "../modules/personalize"
  agent_id    = var.agent_id
}


module "filebrowser" {
    source    = "../modules/filebrowser"
    agent_id  = var.agent_id
    count     = data.coder_parameter.web_file.value == "filebrowser" ? 1 : 0
}

module "code-server" {
  source      = "../modules/code-server/"
  agent_id    = var.agent_id
  count       = data.coder_parameter.web_ide.value == "code-server" ? 1 : 0
  folder      = var.workdir
  extensions  = var.extensions
}

module "vscode-web" {
  source      = "../modules/vscode-web/"
  agent_id    = var.agent_id
  count       = data.coder_parameter.web_ide.value == "vscode-web" ? 1 : 0
  folder      = var.workdir
  extensions  = var.extensions
  accept_license  = true
}

module "kasmvnc" {
  source      = "../modules/kasmvnc/"
  agent_id    = var.agent_id
  count       = data.coder_parameter.web_vnc.value == "kasmvnc" ? 1 : 0
  depends_on = [ module.code-server, module.vscode-web ]
}


data "coder_parameter" "web_file" {
  type          = "string"
  name          = "web_file"
  display_name  = "Web Filebrowser"
  default       = "none"
  description   = "Would you like to use a Web Filebrowser for your workspace?"
  mutable       = true
  order         = 2
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
  order         = 4
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

data "coder_parameter" "web_vnc" {
  type          = "string"
  name          = "web_vnc"
  display_name  = "Web VNC"
  default       = "none"
  description   = "Would you like to use a Web VNC for your workspace?"
  mutable       = true
  order         = 6
  icon          = ""

  option {
    name  = "kasmvnc"
    value = "kasmvnc"
    icon  = "/icon/kasmvnc.svg"
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

output "web_vnc" {
  value = data.coder_parameter.web_vnc.value
}
