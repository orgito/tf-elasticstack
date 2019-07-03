output "dns_name" {
  value = "${aws_lb.lb.dns_name}"
}

output "arn" {
  value = "${aws_lb.lb.arn}"
}
