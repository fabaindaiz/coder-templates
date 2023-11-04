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

variable "port" {
  type        = number
  description = "The port to run KasmVNC on."
  default     = 8444
}

variable "log_path" {
  type        = string
  description = "The path to log."
  default     = "/tmp/kasmvnc.log"
}

resource "coder_script" "kasmvnc" {
  agent_id     = var.agent_id
  display_name = "KasmVNC"
  icon         = "/icon/kasmvnc.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port,
  })
  run_on_start = true
}

resource "coder_app" "kasmvnc" {
  agent_id     = var.agent_id
  slug         = "kasmvnc"
  display_name = "KasmVNC"
  url          = "https://localhost:${var.port}"
  icon         = "/icon/kasmvnc.svg"
  subdomain    = true
  share        = "owner"
}
