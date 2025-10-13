terraform {
  required_version = ">= 1.3"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.2.0"
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
    "dart" = {
      name = "Dart",
      value = "dart",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg",
      extensions = [ "Dart-Code.dart-code", "Dart-Code.flutter" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "dart:latest",
      user =  "",
      script = <<-EOT
RUN echo -e '\nexport PATH="/usr/lib/dart/bin:$PATH"' >> /home/${var.username}/.bashrc
EOT
    },
    "gcc" = {
      name = "C/C++",
      value = "gcc",
      icon = "/icon/cpp.svg",
      extensions = [ "ms-vscode.cpptools", "ms-vscode.cmake-tools", "llvm-vs-code-extensions.vscode-clangd" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "gcc:latest",
      user =  "",
      script = <<-EOT
RUN sudo apt-get -y install \
      gdb
EOT
    },
    "golang" = {
      name = "Go",
      value = "golang",
      icon = "/icon/go.svg",
      extensions = [ "golang.go" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "golang:latest",
      user =  "",
      script = <<-EOT
RUN echo -e '\nexport PATH="/usr/local/go/bin:$PATH"' >> /home/${var.username}/.bashrc
EOT
    },
    "haskell" = {
      name = "Haskell",
      value = "haskell",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/haskell/haskell-original.svg",
      extensions = [ "haskell.haskell" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "haskell:latest",
      user =  "",
      script = <<-EOT
RUN echo -e '\nexport PATH="/opt/ghc/$(ls -1 /opt/ghc | sort -V | tail -n1)/bin/:$PATH"' >> /home/${var.username}/.bashrc
EOT
    },
    "java" = {
      name = "Java",
      value = "java",
      icon = "/icon/java.svg",
      extensions = [ "vscjava.vscode-java-pack" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "eclipse-temurin:latest",
      user =  "",
      script = <<-EOT
EOT
    },
    "julia" = {
      name = "Julia",
      value = "julia",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/julia/julia-original.svg",
      extensions = [ "julialang.language-julia" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "julia:latest",
      user =  "",
      script = <<-EOT
RUN echo -e '\nexport PATH="/usr/local/julia/bin:$PATH"' >> /home/${var.username}/.bashrc
EOT
    },
    "llvm" = {
      name = "LLVM",
      value = "llvm",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/llvm/llvm-original.svg",
      extensions = [ "ocamllabs.ocaml-platform" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "ocaml/opam:debian-12-ocaml-4.14",
      user = "opam",
      script = <<-EOT
RUN sudo apt-get -y install \
      build-essential \
      clang-19 \
      cmake \
      libzstd-dev \
      llvm-19-dev \
      python3.11 \
      zlib1g-dev
RUN sudo ln -f /usr/bin/opam-2.4 /usr/bin/opam \
 && opam init --reinit -ni \
 && opam -y install \
      ocaml-lsp-server \
      ocamlformat \
      earlybird \
      merlin \
      utop
EOT
    },
    "mariadb" = {
      name = "MariaDB",
      value = "mariadb",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg",
      extensions = [ "cweijan.vscode-mysql-client2" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "mariadb:latest",
      user = null,
      script = <<-EOT
EOT
    },
    "node" = {
      name = "Node.js",
      value = "node",
      icon = "/icon/node.svg",
      extensions = [ "angular.ng-template", "vue.volar", "christian-kohler.npm-intellisense" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "node:latest",
      user = null,
      script = <<-EOT
RUN npm install --global \
      yarn
EOT
    },
    "ocaml" = {
      name = "OCaml",
      value = "ocaml",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ocaml/ocaml-original.svg",
      extensions = [ "ocamllabs.ocaml-platform" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "ocaml/opam:latest",
      user = "opam",
      script = <<-EOT
RUN sudo apt-get -y install \
      build-essential \
      clang \
      gdb \
      nasm
RUN sudo ln -f /usr/bin/opam-2.4 /usr/bin/opam \
 && opam-2.4 update \
 && opam-2.4 -y install \
      ocaml-lsp-server \
      ocamlformat \
      earlybird \
      merlin \
      utop
EOT
    },
    "perl" = {
      name = "Perl",
      value = "perl",
      icon = "https://cdn.jsdelivr.net/gh/devicons/devicon/icons/perl/perl-original.svg",
      extensions = [ "richterger.perl" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "perl:latest",
      user =  "",
      script = <<-EOT
EOT
    },
    "php" = {
      name = "PHP",
      value = "php",
      icon = "/icon/php.svg",
      extensions = [ "devsense.phptools-vscode" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "php:latest",
      user =  "",
      script = <<-EOT
EOT
    },
    "python" = {
      name = "Python",
      value = "python",
      icon = "/icon/python.svg",
      extensions = [ "ms-python.python", "ms-python.debugpy", "ms-python.vscode-pylance", "ms-python.mypy-type-checker" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "python:latest",
      user =  "",
      script = <<-EOT
RUN sudo apt-get -y install \
      pipx \
 && pipx install jupyterlab
EOT
    },
    "racket" = {
      name = "Racket",
      value = "racket",
      icon = "https://upload.wikimedia.org/wikipedia/commons/c/c1/Racket-logo.svg",
      extensions = [ "evzen-wybitul.magic-racket" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "racket/racket:latest",
      user =  "",
      script = <<-EOT
raco pkg install --auto racket-lang-server
EOT
    },
    "rlang" = {
      name = "R",
      value = "rlang",
      icon = "/icon/rstudio.svg",
      extensions = [ "REditorSupport.r" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "r-base:latest",
      user = null,
      script = <<-EOT
EOT
    },
    "rocq" = {
      name = "Rocq",
      value = "rocq",
      icon = "https://upload.wikimedia.org/wikipedia/commons/d/d8/Coq_logo.png",
      extensions = [ "maximedenes.vscoq" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "rocq/rocq-prover:latest",
      user = "rocq",
      script = <<-EOT
RUN opam update \
 && opam -y install \
      vsrocq-language-server
EOT
    },
    "ruby" = {
      name = "Ruby",
      value = "ruby",
      icon = "/icon/ruby.png",
      extensions = [ "rebornix.ruby" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "ruby:latest",
      user =  "",
      script = <<-EOT
EOT
    },
    "rust" = {
      name = "Rust",
      value = "rust",
      icon = "/icon/rust.svg",
      extensions = [ "rust-lang.rust-analyzer" ],
      dockerfile = "base.Dockerfile.tftpl",
      image = "rust:latest",
      user =  "",
      script = <<-EOT
RUN echo -e '\nexport PATH="/usr/local/cargo/bin:$PATH"' >> /home/${var.username}/.bashrc
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

data "coder_parameter" "docker_image_debug" {
  type          = "bool"
  name          = "docker_debug"
  display_name  = "Docker image debug"
  default       = false
  description   = "Enable debugging for the Docker image."
  mutable       = true
  icon          = "/icon/docker.png"
}


data "template_file" "dockerfile" {
  template = file("${path.module}/${local.workspaces[data.coder_parameter.docker_image.value].dockerfile}")
  vars = {
    image = local.workspaces[data.coder_parameter.docker_image.value].image
    script = trimspace(local.workspaces[data.coder_parameter.docker_image.value].script)
    baseuser = local.workspaces[data.coder_parameter.docker_image.value].user
    workuser = coalesce(local.workspaces[data.coder_parameter.docker_image.value].user, var.username)
  }
}

resource "local_file" "dockerfile" {
  content  = data.template_file.dockerfile.rendered
  filename = "${path.module}/${data.coder_parameter.docker_image.value}.Dockerfile"
}

resource "null_resource" "debug_dockerfile" {
  count       = data.coder_parameter.docker_image_debug.value == "true" ? 1 : 0

  provisioner "local-exec" {
    command = "cat ${local_file.dockerfile.filename}"
    interpreter = ["bash", "-c"]
  }
}


output "image" {
  value = data.coder_parameter.docker_image.value
}

output "image_tag" {
  value = data.coder_parameter.docker_image_tag.value
}

output "workdir" {
  value = "/home/${coalesce(local.workspaces[data.coder_parameter.docker_image.value].user, var.username)}"
}

output "dockerfile" {
  value = local_file.dockerfile
}

output "extensions" {
  value = local.workspaces[data.coder_parameter.docker_image.value].extensions
}
