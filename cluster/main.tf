resource "null_resource" "validate_worspace" {
  count = "${terraform.workspace == var.stage ? 0 : 1}"
  "\nERROR: You are trying to run ${var.stage} stage in the ${terraform.workspace} workspace.\nCreate/Select the correct workspace first." = true
}

data "aws_region" "current" {}

data "aws_subnet" "selected" {
  count = "${length(var.subnets)}"
  id    = "${var.subnets[count.index]}"
  vpc_id = "${var.vpc}"
}

locals {
  azs = "${data.aws_subnet.selected.*.availability_zone}"
}
