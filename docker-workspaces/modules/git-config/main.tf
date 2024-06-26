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

variable "allow_username_change" {
  type        = bool
  description = "Allow developers to change their git username."
  default     = true
}

variable "allow_email_change" {
  type        = bool
  description = "Allow developers to change their git email."
  default     = false
}


data "coder_workspace" "me" {}

data "coder_parameter" "user_email" {
  count        = var.allow_email_change ? 1 : 0
  name         = "user_email"
  type         = "string"
  default      = ""
  description  = "Git user.email to be used for commits. Leave empty to default to Coder user's email."
  display_name = "Git config user.email"
  mutable      = true
  icon = "/icon/git.svg"
}

data "coder_parameter" "username" {
  count        = var.allow_username_change ? 1 : 0
  name         = "username"
  type         = "string"
  default      = ""
  description  = "Git user.name to be used for commits. Leave empty to default to Coder user's Full Name."
  display_name = "Full Name for Git config"
  mutable      = true
  icon = "/icon/git.svg"
}

resource "coder_env" "git_author_name" {
  agent_id = var.agent_id
  name     = "GIT_AUTHOR_NAME"
  value    = try(data.coder_parameter.username[0].value, "") == "" ? data.coder_workspace.me.owner : try(data.coder_parameter.username[0].value, "")
}

resource "coder_env" "git_commmiter_name" {
  agent_id = var.agent_id
  name     = "GIT_COMMITTER_NAME"
  value    = try(data.coder_parameter.username[0].value, "") == "" ? data.coder_workspace.me.owner : try(data.coder_parameter.username[0].value, "")
}

resource "coder_env" "git_author_email" {
  agent_id = var.agent_id
  name     = "GIT_AUTHOR_EMAIL"
  value    = try(data.coder_parameter.user_email[0].value, "") == "" ? data.coder_workspace.me.owner_email : try(data.coder_parameter.user_email[0].value, "")
}

resource "coder_env" "git_commmiter_email" {
  agent_id = var.agent_id
  name     = "GIT_COMMITTER_EMAIL"
  value    = try(data.coder_parameter.user_email[0].value, "") == "" ? data.coder_workspace.me.owner_email : try(data.coder_parameter.user_email[0].value, "")
}
