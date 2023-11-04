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


locals {
  workspaces ={
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
    "python" = {
      name = "Python",
      value = "python",
      icon = "/icon/python.svg",
      workdir = "/home/coder",
      extensions = [ "ms-python.python" ]
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

data "coder_parameter" "cpu" {
  name        = "CPU cores"
  type        = "number"
  description = "CPU cores for your individual workspace"
  icon        = "https://png.pngtree.com/png-clipart/20191122/original/pngtree-processor-icon-png-image_5165793.jpg"
  validation {
    min       = 1
    max       = 4
  }
  mutable     = true
  default     = 1
  order       = 1  
}

data "coder_parameter" "memory" {
  name        = "Memory (__ GB)"
  type        = "number"
  description = "Memory (__ GB) for your individual workspace"
  icon        = "https://www.vhv.rs/dpng/d/33-338595_random-access-memory-logo-hd-png-download.png"
  validation {
    min       = 1
    max       = 8
  }
  mutable     = true
  default     = 2
  order       = 2  
}

data "coder_parameter" "disk_size" {
  name        = "PVC storage size"
  type        = "number"
  description = "Number of GB of storage for /home/coder and this will persist even when the workspace's Kubernetes pod and container are shutdown and deleted"
  icon        = "https://www.pngall.com/wp-content/uploads/5/Database-Storage-PNG-Clipart.png"
  validation {
    min       = 1
    max       = 20
    monotonic = "increasing"
  }
  mutable     = true
  default     = 10
  order       = 3  
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
