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


locals {
  workspaces ={
    "coq" = {
      name = "Coq",
      value = "coqorg/coq",
      icon = "https://upload.wikimedia.org/wikipedia/commons/d/d8/Coq_logo.png",
      workdir = "/home/coq",
      extensions = [ "maximedenes.vscoq" ],
      install_script = <<-EOT
        opam update \
     && opam -y install \
          vscoq-language-server
      EOT
    },
    "dart" = {
      name = "Dart",
      value = "dart",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg",
      workdir = "/home/coder",
      extensions = [ "Dart-Code.dart-code", "Dart-Code.flutter" ],
      install_script = <<-EOT
      EOT
    },
    "gcc" = {
      name = "C/C++",
      value = "gcc",
      icon = "/icon/cpp.svg",
      workdir = "/home/coder",
      extensions = [ "llvm-vs-code-extensions.vscode-clangd" ],
      install_script = <<-EOT
      EOT
    },
    "golang" = {
      name = "Go",
      value = "golang",
      icon = "/icon/go.svg",
      workdir = "/home/coder",
      extensions = [ "golang.go" ],
      install_script = <<-EOT
      EOT
    },
    "haskell" = {
      name = "Haskell",
      value = "haskell",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/haskell/haskell-original.svg",
      workdir = "/home/coder",
      extensions = [ "haskell.haskell" ],
      install_script = <<-EOT
      EOT
    },
    "java" = {
      name = "Java",
      value = "eclipse-temurin",
      icon = "/icon/java.svg",
      workdir = "/home/coder",
      extensions = [ "vscjava.vscode-java-pack" ],
      install_script = <<-EOT
      EOT
    },
    "julia" = {
      name = "Julia",
      value = "julia",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/julia/julia-original.svg",
      workdir = "/home/coder",
      extensions = [ "julialang.language-julia" ],
      install_script = <<-EOT
      EOT
    },
    "mariadb" = {
      name = "MariaDB",
      value = "mariadb",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg",
      workdir = "/home/mysql",
      extensions = [ "cweijan.vscode-mysql-client2" ],
      install_script = <<-EOT
      EOT
    },
    "node" = {
      name = "Node.js",
      value = "node",
      icon = "/icon/node.svg",
      workdir = "/home/node",
      extensions = [ "christian-kohler.npm-intellisense", "eg2.vscode-npm-script" ],
      install_script = <<-EOT
      EOT
    },
    "ocaml" = {
      name = "OCaml",
      value = "ocaml/opam",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ocaml/ocaml-original.svg",
      workdir = "/home/opam",
      extensions = [ "ocamllabs.ocaml-platform" ],
      install_script = <<-EOT
        opam-2.2 init -y \
     && opam-2.2 update \
     && eval `opam-2.2 env` \
     && opam-2.2 -y install \
          ocaml-lsp-server \
          ocamlformat-rpc
      EOT
    },
    "perl" = {
      name = "Perl",
      value = "perl",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/perl/perl-original.svg",
      image = "perl:latest",
      workdir = "/home/coder",
      extensions = [ "richterger.perl" ],
      install_script = <<-EOT
      EOT
    },
    "php" = {
      name = "PHP",
      value = "php",
      icon = "/icon/php.svg",
      image = "php:latest",
      workdir = "/home/coder",
      extensions = [ "bmewburn.vscode-intelephense-client" ],
      install_script = <<-EOT
      EOT
    },
    "python" = {
      name = "Python",
      value = "python",
      icon = "/icon/python.svg",
      image = "python:latest",
      workdir = "/home/coder",
      extensions = [ "ms-python.python" ],
      install_script = <<-EOT
      EOT
    },
    "racket" = {
      name = "Racket",
      value = "racket",
      icon = "https://upload.wikimedia.org/wikipedia/commons/c/c1/Racket-logo.svg",
      image = "racket/racket:latest",
      workdir = "/home/coder",
      extensions = [ "evzen-wybitul.magic-racket" ],
      install_script = <<-EOT
      raco pkg install --auto racket-lang-server
      EOT
    },
    "rlang" = {
      name = "R",
      value = "rbase",
      icon = "/icon/rstudio.svg",
      image = "r-base:latest",
      workdir = "/home/docker",
      extensions = [ "REditorSupport.r" ],
      install_script = <<-EOT
      EOT
    },
    "ruby" = {
      name = "Ruby",
      value = "ruby",
      icon = "/icon/ruby.png",
      image = "ruby:latest",
      workdir = "/home/coder",
      extensions = [ "rebornix.ruby" ],
      install_script = <<-EOT
      EOT
    },
    "rust" = {
      name = "Rust",
      value = "rust",
      icon = "/icon/rust.svg",
      image = "rust:latest",
      workdir = "/home/coder",
      extensions = [ "rust-lang.rust-analyzer" ],
      install_script = <<-EOT
      EOT
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

data "coder_parameter" "docker_image_tag" {
  type          = "string"
  name          = "docker_tag"
  display_name  = "Docker image tag"
  default       = ""
  description   = "Specify the Docker image tag. Changing this tag triggers a rebuild."
  mutable       = true
  icon          = "/icon/docker.png"
}


output "image" {
  value = data.coder_parameter.docker_image.value
}

output "image_tag" {
  value = data.coder_parameter.docker_image_tag.value
}

output "workdir" {
  value = local.workspaces[data.coder_parameter.docker_image.value].workdir
}

output "extensions" {
  value = local.workspaces[data.coder_parameter.docker_image.value].extensions
}
