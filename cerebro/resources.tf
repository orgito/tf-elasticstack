resource "aws_instance" "node" {
  ami                    = "${var.ami}"
  subnet_id              = "${var.subnet}"
  instance_type          = "${var.type}"
  vpc_security_group_ids = ["${aws_security_group.cerebro.id}"]
  key_name               = "${var.ssh_key_pair}"

  root_block_device {
    delete_on_termination = true
  }

  user_data = "${data.template_cloudinit_config.provision.rendered}"

  tags = {
    Name        = "${var.name}"
    Environment = "${var.stage}"
    Role        = "cerebro"
    Provision   = "terraform"
    Inventory   = "ansible"
  }

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }
}

# Security Group
resource "aws_security_group" "cerebro" {
  name        = "${var.name}"
  description = "Allow inbound traffic to cerebro"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}"
    Environment = "${var.stage}"
    Provision   = "terraform"
  }
}
