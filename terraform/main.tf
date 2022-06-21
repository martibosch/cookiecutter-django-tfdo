terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
    sshclient = {
      source  = "luma-planet/sshclient"
      version = "~> 1.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "exaf-epfl"
    workspaces {
      tags = ["cookiecutter-django-tfdo-demo"]
    }
  }
}

provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "digitalocean_ssh_key" "ssh_key" {
  name       = var.ssh_key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

module "droplet" {
  source       = "martibosch/docker-compose-host/digitalocean"
  version      = "0.2.12"
  droplet_name = "${var.resource_prefix}-${var.env}"
  do_token     = var.do_token

  image                  = var.droplet_image
  region                 = var.region
  size                   = var.droplet_size
  docker_compose_version = var.docker_compose_version
  ssh_keys = [
    digitalocean_ssh_key.ssh_key.id
  ]
  user            = var.droplet_user
  ssh_private_key = tls_private_key.ssh.private_key_openssh

  domain  = var.domain
  records = var.records

  init_script     = "./serve-${var.env}.sh"
  compose_app_dir = ".."
  droplet_app_dir = "/home/ubuntu/app"
}

resource "digitalocean_spaces_bucket" "bucket" {
  name          = "${var.resource_prefix}-${var.env}"
  acl           = "public-read"
  force_destroy = true
  region        = var.region

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = var.cors_allowed_origins
  }
}

data "github_repository" "repo" {
  full_name = var.repo_name
}

resource "github_repository_environment" "digitalocean_environment" {
  repository  = data.github_repository.repo.full_name
  environment = "digitalocean"
}

resource "github_actions_environment_secret" "ssh" {
  repository      = data.github_repository.repo.name
  environment     = github_repository_environment.digitalocean_environment.environment
  secret_name     = "ssh_key"
  plaintext_value = tls_private_key.ssh.private_key_pem
}

data "sshclient_host" "host" {
  hostname                 = module.droplet.ipv4_address
  username                 = "keyscan"
  insecure_ignore_host_key = true # we use this to scan and obtain the key
}

data "sshclient_keyscan" "keyscan" {
  host_json = data.sshclient_host.host.json
}

resource "github_actions_environment_secret" "known_hosts" {
  repository      = data.github_repository.repo.name
  environment     = github_repository_environment.digitalocean_environment.environment
  secret_name     = "known_hosts"
  plaintext_value = "${data.sshclient_keyscan.keyscan.id} ${data.sshclient_keyscan.keyscan.authorized_key}"
}
