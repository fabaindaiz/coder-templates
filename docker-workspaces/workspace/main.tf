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
      value = "coq",
      icon = "https://upload.wikimedia.org/wikipedia/commons/d/d8/Coq_logo.png",
      workdir = "/home/coq",
      extensions = [ "maximedenes.vscoq" ]
    },
    "dart" = {
      name = "Dart",
      value = "dart",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg",
      workdir = "/home/coder",
      extensions = [ "Dart-Code.dart-code", "Dart-Code.flutter" ]
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
      extensions = [ "vscjava.vscode-java-pack" ]
    },
    "julia" = {
      name = "Julia",
      value = "julia",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/julia/julia-original.svg",
      workdir = "/home/coder",
      extensions = [ "julialang.language-julia" ]
    },
    "mysql" = {
      name = "MariaDB",
      value = "mysql",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg",
      workdir = "/home/mysql",
      extensions = [ "cweijan.vscode-mysql-client2" ]
    },
    "node" = {
      name = "Node.js",
      value = "node",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nodejs/nodejs-original.svg",
      workdir = "/home/node",
      extensions = [ "christian-kohler.npm-intellisense", "eg2.vscode-npm-script" ]
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
    "php" = {
      name = "PHP",
      value = "php",
      icon = "/icon/php.svg",
      workdir = "/home/coder",
      extensions = [ "bmewburn.vscode-intelephense-client" ]
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
    "rlang" = {
      name = "R",
      value = "rbase",
      icon = "/icon/rstudio.svg",
      workdir = "/home/docker",
      extensions = [ "REditorSupport.r" ]
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
      extensions = [ "rust-lang.rust-analyzer" ]
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
