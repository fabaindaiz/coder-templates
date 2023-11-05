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


module "kasmvnc" {
  source      = "./modules/kasmvnc/"
  agent_id    = var.agent_id
  count       = data.coder_parameter.web_vnc.value == "kasmvnc" ? 1 : 0
  depends_on = [ module.code-server, module.vscode-web ]
}


data "coder_parameter" "web_vnc" {
  type          = "string"
  name          = "web_vnc"
  display_name  = "Web VNC"
  default       = "none"
  description   = "Would you like to use a Web VNC for your workspace?"
  mutable       = true
  order         = 3
  icon          = "https://upload.wikimedia.org/wikipedia/commons/a/ae/Monitor_Display_Flat_Icon_Vector.svg"

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

output "web_vnc" {
  value = data.coder_parameter.web_vnc.value
}
