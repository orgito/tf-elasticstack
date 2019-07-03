data "aws_region" "current" {}

data "aws_subnet" "selected" {
  count  = "${length(var.subnets)}"
  id     = "${var.subnets[count.index]}"
  vpc_id = "${var.vpc}"
}

locals {
  azs       = "${data.aws_subnet.selected.*.availability_zone}"
  safe_name = "${replace(var.name, "_", "-")}"
}
