resource "aws_lb" "lb" {
  name               = "${var.name}"
  internal           = true
  security_groups    = ["${aws_security_group.lb.id}"]
  subnets            = ["${var.subnets}"]
  load_balancer_type = "${var.type}"

  enable_cross_zone_load_balancing = true

  tags = {
    Name        = "${var.name}"
    Environment = "${var.stage}"
    Provision   = "terraform"
    Inventory   = "ansible"
  }
}

resource "aws_security_group" "lb" {
  name        = "${var.name}"
  description = "Load Balancer Security Group"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 0
    to_port     = 65535
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
