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

variable "resource_id" {
  type        = string
  description = "The ID of a Coder resource."
}


locals {
  workspaces ={
    "python" = {
      name = "Python",
      value = "python",
      icon = "/icon/python.svg",
      workdir = "/home/coder",
      extensions = [ "ms-python.python" ]
    },
    "coq" = {
      name = "Coq",
      value = "coq",
      icon = "https://upload.wikimedia.org/wikipedia/commons/d/d8/Coq_logo.png",
      workdir = "/home/coq",
      extensions = [ "maximedenes.vscoq" ]
    },
    "gcc" = {
      name = "C/C++",
      value = "gcc",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/gcc/gcc-original.svg",
      workdir = "/home/coder",
      extensions = [ "llvm-vs-code-extensions.vscode-clangd" ]
    },
    "golang" = {
      name = "Go",
      value = "golang",
      icon = "/icon/go.svg",
      workdir = "/home/coder",
      extensions = [ "golang.go" ]
    },
    "haskell" = {
      name = "Haskell",
      value = "haskell",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/haskell/haskell-original.svg",
      workdir = "/home/coder",
      extensions = [ "haskell.haskell" ]
    },
    "java" = {
      name = "Java",
      value = "java",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/java/java-original.svg",
      workdir = "/home/coder",
      extensions = [ "redhat.java" ]
    },
    "node" = {
      name = "Node.js",
      value = "node",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg",
      workdir = "/home/node",
      extensions = [ "eg2.vscode-npm-script" ]
    },
    "ocaml" = {
      name = "OCaml",
      value = "ocaml",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ocaml/ocaml-original.svg",
      workdir = "/home/opam",
      extensions = [ "ocamllabs.ocaml-platform" ]
    },
    "perl" = {
      name = "Perl",
      value = "perl",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/perl/perl-original.svg",
      workdir = "/home/coder",
      extensions = [ "richterger.perl" ]
    },
    "racket" = {
      name = "Racket",
      value = "racket",
      icon = "https://upload.wikimedia.org/wikipedia/commons/c/c1/Racket-logo.svg",
      workdir = "/home/coder",
      extensions = [ "evzen-wybitul.magic-racket" ]
    },
    "ruby" = {
      name = "Ruby",
      value = "ruby",
      icon = "/icon/ruby.png",
      workdir = "/home/coder",
      extensions = [ "rebornix.ruby" ]
    },
    "rust" = {
      name = "Rust",
      value = "rust",
      icon = "/icon/rust.svg",
      workdir = "/home/coder",
      extensions = [ "rust-lang.rust" ]
    }
  }
}


data "coder_parameter" "docker_image" {
  type          = "string"
  name          = "docker_image"
  display_name  = "Docker image"
  default       = "python"
  description   = "What Docker image would you like to use for your workspace?"
  mutable       = false
  icon          = "/icon/docker.png"

  dynamic "option" {
    for_each = local.workspaces
    content {
      name  = option.value.name
      value = option.value.value
      icon  = option.value.icon
    }
  }
}


data "coder_workspace" "me" {}

resource "coder_metadata" "container_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = var.resource_id

  item {
    key   = "var_image"
    value = module.workspace.image
  }
  item {
    key   = "var_workdir"
    value = module.workspace.workdir
  }
}


output "image" {
  value = data.coder_parameter.docker_image.value
}

output "workdir" {
  value = local.workspaces[data.coder_parameter.docker_image.value].workdir
}

output "extensions" {
  value = local.workspaces[data.coder_parameter.docker_image.value].extensions
}
