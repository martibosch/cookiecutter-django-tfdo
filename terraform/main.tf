provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}

data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
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
    data.digitalocean_ssh_key.ssh_key.id
  ]
  user = var.droplet_user

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
