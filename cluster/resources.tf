resource "aws_instance" "node" {
  count                  = "${var.instance_count}"
  ami                    = "${var.ami}"
  subnet_id              = "${element(var.subnets, count.index)}"
  availability_zone      = "${element(local.azs, count.index)}"
  instance_type          = "${var.type}"
  vpc_security_group_ids = ["${var.groups}"]
  iam_instance_profile   = "${var.iam_profile}"
  key_name               = "${var.ssh_key_pair}"

  depends_on = ["aws_ebs_volume.node"]

  root_block_device {
    delete_on_termination = true
  }

  user_data = "${var.user_data}"

  tags = {
    Name        = "${var.name}${count.index}"
    Environment = "${var.stage}"
    ClusterName = "${var.name}"
    Role        = "${var.role}"
    Provision   = "terraform"
    Inventory   = "ansible"
  }

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }
}

resource "aws_ebs_volume" "node" {
  count             = "${var.storage_size == 0 ? 0 : var.instance_count}"
  availability_zone = "${element(local.azs, count.index)}"
  type              = "gp2"
  size              = "${var.storage_size}"

  tags = {
    Name        = "${var.name}${count.index}"
    Environment = "${var.stage}"
    Provision   = "terraform"
  }
}

resource "aws_volume_attachment" "node" {
  count        = "${var.storage_size == 0 ? 0 : var.instance_count}"
  device_name  = "/dev/xvdg"
  volume_id    = "${element(aws_ebs_volume.node.*.id, count.index)}"
  instance_id  = "${element(aws_instance.node.*.id, count.index)}"
  skip_destroy = true

  lifecycle {
    ignore_changes = ["volume_id", "instance_id"]
  }
}
