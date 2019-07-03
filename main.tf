provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "null_resource" "validate_worspace" {
  count = "${terraform.workspace == var.stage ? 0 : 1}"
  "\nERROR: You are trying to run ${var.stage} stage in the ${terraform.workspace} workspace.\nCreate/Select the correct workspace first." = true
}


data "aws_vpc" "vpc" {
  id = "${var.vpc}"
}

# Amazon Linux 2
data "aws_ami" "selected" {
  owners      = ["137112412989"] # Amazon
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Necessary to accept the license aggrement if the AMI was never used before
data "aws_ami" "centos" {
  owners      = ["679593333241"] # CentOS
  most_recent = true

  filter {
    name   = "name"
    values = ["*CentOS Linux 7 x86_64 HVM EBS ENA 1805_01*"]
  }
}

locals {
  safe_prefix = "${replace(lower("${var.namespace}${var.stage}"), "_", "-")}"
}

data "template_file" "pipeline" {
  template = "${file("${path.module}/files/logstash.conf")}"

  vars {
    elasticsearch_lb_host = "${module.alb.dns_name}"
  }
}
