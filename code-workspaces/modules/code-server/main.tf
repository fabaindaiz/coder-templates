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

variable "extensions" {
  type        = list(string)
  description = "A list of extensions to install."
  default     = []
}

variable "port" {
  type        = number
  description = "The port to run code-server on."
  default     = 13337
}

variable "folder" {
  type        = string
  description = "The folder to open in code-server."
  default     = ""
}

variable "log_path" {
  type        = string
  description = "The path to log code-server to."
  default     = "/tmp/code-server.log"
}

variable "install_version" {
  type        = string
  description = "The version of code-server to install."
  default     = ""
}

variable "install_prefix" {
  type        = string
  description = "The prefix to install code-server to."
  default     = "/tmp/code-server"
}

variable "settings" {
  type        = map(string)
  description = "A map of settings to apply to code-server."
  default     = {}
}

resource "coder_script" "code-server" {
  agent_id     = var.agent_id
  display_name = "Code Server Web"
  icon         = "/icon/code.svg"
  script = templatefile("${path.module}/run.sh", {
    VERSION : var.install_version,
    INSTALL_PREFIX : var.install_prefix,
    PORT : var.port,
    LOG_PATH : var.log_path,
    EXTENSIONS : join(",", var.extensions),
    // This is necessary otherwise the quotes are stripped!
    SETTINGS : replace(jsonencode(var.settings), "\"", "\\\""),
  })
  run_on_start = true
}

resource "coder_app" "code-server" {
  agent_id     = var.agent_id
  slug         = "code-server"
  display_name = "Code Server Web"
  url          = "http://localhost:${var.port}/${var.folder != "" ? "?folder=${urlencode(var.folder)}" : ""}"
  icon         = "/icon/code.svg"
  subdomain    = true
  share        = "owner"

  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}
