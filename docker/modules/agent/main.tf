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

variable "start_count" {
  type        = number
  description = "Start count of the workspace"
  default     = 1
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
