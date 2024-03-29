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
  description = "The port to run VS Code Web on."
  default     = 13338
}

variable "folder" {
  type        = string
  description = "The folder to open in vscode-web."
  default     = ""
}

variable "log_path" {
  type        = string
  description = "The path to log."
  default     = "/tmp/vscode-web.log"
}

variable "accept_license" {
  type        = bool
  description = "Accept the VS Code license. https://code.visualstudio.com/license"
  default     = false
  validation {
    condition     = var.accept_license == true
    error_message = "You must accept the VS Code license agreement by setting accept_license=true."
  }
}

resource "coder_script" "vscode-web" {
  agent_id     = var.agent_id
  display_name = "VS Code Web"
  icon         = "/icon/code.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port,
    EXTENSIONS : join(",", var.extensions),
  })
  run_on_start = true
}

resource "coder_app" "vscode-web" {
  agent_id     = var.agent_id
  slug         = "vscode-web"
  display_name = "VS Code Web"
  url          = var.folder == "" ? "http://localhost:${var.port}" : "http://localhost:${var.port}?folder=${var.folder}"
  icon         = "/icon/code.svg"
  subdomain    = true
  share        = "owner"

  healthcheck {
    url       = "http://localhost:${var.port}/healthz"
    interval  = 5
    threshold = 6
  }
}
