terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.2.0"
    }
  }
}


variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "image" {
  type        = string
  description = "The image to use for the workspace."
}

variable "workdir" {
  type        = string
  description = "The working directory of the workspace."
}

variable "extensions" {
  type        = list(string)
  description = "The list of extensions to install."
}

variable "start_count" {
  type        = number
  description = "Start count of the workspace"
  default     = 1
}


module "dotfiles" {
  source      = "registry.coder.com/modules/dotfiles/coder"
  count       = var.start_count
  agent_id    = var.agent_id
}

module "git-config" {
  source      = "registry.coder.com/modules/git-config/coder"
  count       = var.start_count
  agent_id    = var.agent_id
  allow_email_change = true
}

module "git-signing" {
  source      = "registry.coder.com/coder/git-commit-signing/coder"
  count       = var.start_count
  agent_id    = var.agent_id
}

module "personalize" {
  source      = "registry.coder.com/modules/personalize/coder"
  count       = var.start_count
  agent_id    = var.agent_id
}


module "vscode" {
  source      = "registry.coder.com/coder/vscode-desktop/coder"
  count       = var.start_count
  agent_id    = var.agent_id
  folder      = var.workdir
  group       = "Desktop Apps"
  open_recent = true
  order       = 1
}

module "cursor" {
  source      = "registry.coder.com/modules/cursor/coder"
  count       = var.start_count
  agent_id    = var.agent_id
  folder      = var.workdir
  group       = "Desktop Apps"
  open_recent = true
  order       = 2
}

module "fleet" {
  source      = "registry.coder.com/coder/jetbrains-fleet/coder"
  count       = var.start_count
  agent_id    = var.agent_id
  folder      = var.workdir
  group       = "Desktop Apps"
  order       = 3
}

module "jupyter" {
  source      = "registry.coder.com/coder/jupyterlab/coder"
  count       = var.image == "python" ? var.start_count : 0
  agent_id    = var.agent_id
  group       = "Browser Apps"
  order       = 3
}


module "code-server" {
  source      = "registry.coder.com/modules/code-server/coder"
  count       = data.coder_parameter.web_code.value == "code-server" ? var.start_count : 0
  agent_id    = var.agent_id
  folder      = var.workdir
  extensions  = var.extensions
  auto_install_extensions = true
  group       = "Browser Apps"
  order       = 2
}

module "code-vscode" {
  source      = "registry.coder.com/modules/vscode-web/coder"
  count       = data.coder_parameter.web_code.value == "code-vscode" ? var.start_count : 0
  agent_id    = var.agent_id
  folder      = var.workdir
  extensions  = var.extensions
  auto_install_extensions = true
  accept_license  = true
  telemetry_level = "off"
  group       = "Browser Apps"
  order       = 2
}

module "claude-code" {
  source      = "registry.coder.com/coder/claude-code/coder"
  count       = data.coder_parameter.web_agent.value == "claude-code" ? var.start_count : 0
  agent_id    = var.agent_id
  folder      = var.workdir
  install_claude_code = true
  claude_code_version = "latest"
  group       = "Browser Apps"
  order       = 4
}

module "filebrowser" {
  source      = "registry.coder.com/modules/filebrowser/coder"
  count       = data.coder_parameter.web_file.value == "file-browser" ? var.start_count : 0
  agent_id    = var.agent_id
  folder      = var.workdir
  group       = "Browser Apps"
  order       = 5
}

module "kasmvnc" {
  source      = "registry.coder.com/modules/kasmvnc/coder"
  count       = data.coder_parameter.web_vnc.value == "vnc-kasmvnc" ? var.start_count : 0
  agent_id    = var.agent_id
  desktop_environment = "xfce"
  group       = "Browser Apps"
  order       = 6
}


data "coder_parameter" "web_code" {
  type          = "string"
  name          = "web_code"
  display_name  = "Web Code Editor"
  default       = "none"
  description   = "Would you like to use a Web Code Editor for your workspace?"
  mutable       = true
  order         = 2
  icon          = "/icon/code.svg"

  option {
    name  = "vscode-web"
    value = "code-vscode"
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

data "coder_parameter" "web_agent" {
  type          = "string"
  name          = "web_agent"
  display_name  = "Web AI Agent"
  default       = "none"
  description   = "Would you like to use a Web AI Agent for your workspace?"
  icon          = "/icon/claude.svg"
  mutable       = true
  order         = 4

  option {
    name  = "claude"
    value = "claude-code"
    icon  = "/icon/claude.svg"
  }
  option {
    name  = "none"
    value = "none"
    icon  = "/emojis/274c.png"
  }
}

data "coder_parameter" "web_file" {
  type          = "string"
  name          = "web_file"
  display_name  = "Web Filebrowser"
  default       = "none"
  description   = "Would you like to use a Web Filebrowser for your workspace?"
  icon          = "/icon/filebrowser.svg"
  mutable       = true
  order         = 5

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
  display_name  = "Web VNC Desktop"
  default       = "none"
  description   = "Would you like to use a Web VNC Desktop for your workspace?"
  icon          = "/icon/kasmvnc.svg"
  mutable       = true
  order         = 6

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


output "web_file" {
  value = data.coder_parameter.web_file.value
}

output "web_vnc" {
  value = data.coder_parameter.web_vnc.value
}

output "web_code" {
  value = data.coder_parameter.web_code.value
}
