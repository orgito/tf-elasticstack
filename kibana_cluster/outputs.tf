output "instance_ids" {
  value = "${module.cluster.instance_ids}"
}

output "private_ips" {
  value = "${module.cluster.private_ips}"
}

output "public_ips" {
  value = "${module.cluster.public_ips}"
}
