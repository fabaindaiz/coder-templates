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

variable "username" {
  type        = string
  description = "The username of the workspace."
}


locals {
  workspaces = {
    "coq" = {
      name = "Coq",
      value = "coqorg/coq",
      icon = "https://upload.wikimedia.org/wikipedia/commons/d/d8/Coq_logo.png",
      user = "coq",
      extensions = [ "maximedenes.vscoq" ],
      script = <<-EOT
        opam update \
     && opam -y install \
          vscoq-language-server
      EOT
    },
    "dart" = {
      name = "Dart",
      value = "dart",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg",
      user =  null,
      extensions = [ "Dart-Code.dart-code", "Dart-Code.flutter" ],
      script = <<-EOT
      EOT
    },
    "gcc" = {
      name = "C/C++",
      value = "gcc",
      icon = "/icon/cpp.svg",
      user =  null,
      extensions = [ "ms-vscode.cpptools", "ms-vscode.cmake-tools", "llvm-vs-code-extensions.vscode-clangd" ],
      script = <<-EOT
      EOT
    },
    "golang" = {
      name = "Go",
      value = "golang",
      icon = "/icon/go.svg",
      user =  null,
      extensions = [ "golang.go" ],
      script = <<-EOT
      EOT
    },
    "haskell" = {
      name = "Haskell",
      value = "haskell",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/haskell/haskell-original.svg",
      user =  null,
      extensions = [ "haskell.haskell" ],
      script = <<-EOT
      EOT
    },
    "java" = {
      name = "Java",
      value = "eclipse-temurin",
      icon = "/icon/java.svg",
      user =  null,
      extensions = [ "vscjava.vscode-java-pack" ],
      script = <<-EOT
      EOT
    },
    "julia" = {
      name = "Julia",
      value = "julia",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/julia/julia-original.svg",
      user =  null,
      extensions = [ "julialang.language-julia" ],
      script = <<-EOT
      EOT
    },
    "mariadb" = {
      name = "MariaDB",
      value = "mariadb",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg",
      user = "mysql",
      extensions = [ "cweijan.vscode-mysql-client2" ],
      script = <<-EOT
      EOT
    },
    "node" = {
      name = "Node.js",
      value = "node",
      icon = "/icon/node.svg",
      user = "node",
      extensions = [ "angular.ng-template", "vue.volar", "christian-kohler.npm-intellisense" ],
      script = <<-EOT
      EOT
    },
    "ocaml" = {
      name = "OCaml",
      value = "ocaml/opam",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ocaml/ocaml-original.svg",
      user = "opam",
      extensions = [ "ocamllabs.ocaml-platform" ],
      script = <<-EOT
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
      user =  null,
      extensions = [ "richterger.perl" ],
      script = <<-EOT
      EOT
    },
    "php" = {
      name = "PHP",
      value = "php",
      icon = "/icon/php.svg",
      image = "php:latest",
      user =  null,
      extensions = [ "devsense.phptools-vscode" ],
      script = <<-EOT
      EOT
    },
    "python" = {
      name = "Python",
      value = "python",
      icon = "/icon/python.svg",
      image = "python:latest",
      user =  null,
      extensions = [ "ms-python.python", "ms-python.debugpy", "ms-python.vscode-pylance", "ms-python.mypy-type-checker" ],
      script = <<-EOT
      EOT
    },
    "racket" = {
      name = "Racket",
      value = "racket",
      icon = "https://upload.wikimedia.org/wikipedia/commons/c/c1/Racket-logo.svg",
      image = "racket/racket:latest",
      user =  null,
      extensions = [ "evzen-wybitul.magic-racket" ],
      script = <<-EOT
      raco pkg install --auto racket-lang-server
      EOT
    },
    "rlang" = {
      name = "R",
      value = "rbase",
      icon = "/icon/rstudio.svg",
      image = "r-base:latest",
      user = "docker",
      extensions = [ "REditorSupport.r" ],
      script = <<-EOT
      EOT
    },
    "ruby" = {
      name = "Ruby",
      value = "ruby",
      icon = "/icon/ruby.png",
      image = "ruby:latest",
      user =  null,
      extensions = [ "rebornix.ruby" ],
      script = <<-EOT
      EOT
    },
    "rust" = {
      name = "Rust",
      value = "rust",
      icon = "/icon/rust.svg",
      image = "rust:latest",
      user =  null,
      extensions = [ "rust-lang.rust-analyzer" ],
      script = <<-EOT
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


data "template_file" "dockerfile" {
  template = file("${path.module}/base.Dockerfile.tftpl")
  vars = {
    image = local.workspaces[data.coder_parameter.docker_image.value].image
    script = local.workspaces[data.coder_parameter.docker_image.value].script
    user = var.username
  }
}

resource "local_file" "dockerfile" {
  content  = data.template_file.dockerfile.rendered
  filename = "${path.module}/${data.coder_parameter.docker_image.value}.Dockerfile"
}


output "image" {
  value = data.coder_parameter.docker_image.value
}

output "image_tag" {
  value = data.coder_parameter.docker_image_tag.value
}

output "dockerfile" {
  value = local_file.dockerfile.filename
}

output "extensions" {
  value = local.workspaces[data.coder_parameter.docker_image.value].extensions
}
