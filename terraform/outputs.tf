output "id" {
  description = "ID of the created droplet."
  value       = module.droplet.id
}

output "name" {
  description = "Name of the created droplet."
  value       = module.droplet.name
}

output "ipv4_address" {
  description = "URL address of the droplet."
  value       = module.droplet.ipv4_address
}

output "bucket_address" {
  description = "URL address of the spaces bucket."
  value       = digitalocean_spaces_bucket.bucket.bucket_domain_name
}
