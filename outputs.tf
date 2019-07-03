output "elasticsearch_private_ips" {
  value = "${module.elasticsearch.private_ips}"
}

output "logstash_private_ips" {
  value = "${module.logstash.private_ips}"
}

output "kibana_private_ips" {
  value = "${module.kibana.private_ips}"
}

output "cerebro_private_ip" {
  value = "${module.cerebro.private_ip}"
}

output "elasticsearch_load_balancer" {
  value = "${module.alb.dns_name}"
}

output "logstash_load_balancer" {
  value = "${aws_lb.nlb.dns_name}"
}

output "kibana_load_balancer" {
  value = "${module.alb.dns_name}"
}

output "elasticsearch_url" {
  value = "http://${module.alb.dns_name}:9200/"
}

output "logstash_beats_host" {
  value = "${aws_lb.nlb.dns_name}:5044"
}

output "logstash_28777_host" {
  value = "${aws_lb.nlb.dns_name}:28777"
}

output "kibana_url" {
  value = "http://${module.alb.dns_name}/"
}

output "cerebro_url" {
  value = "http://${module.cerebro.private_ip}/"
}
