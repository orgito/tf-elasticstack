module "cluster" {
  source = "../cluster"

  ami            = "${var.ami}"
  groups         = ["${aws_security_group.kibana.id}"]
  instance_count = "${var.instance_count}"
  name           = "${var.name}"
  stage          = "${var.stage}"
  role           = "kibana"
  ssh_key_pair   = "${var.ssh_key_pair}"
  subnets        = "${var.subnets}"
  type           = "${var.type}"
  user_data      = "${data.template_cloudinit_config.provision.rendered}"
  vpc            = "${var.vpc}"
}

resource "aws_lb_target_group" "kibana" {
  name     = "${local.safe_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc}"

  health_check {
    interval          = 10
    path              = "/app/kibana"
    healthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "kibana" {
  count            = "${var.instance_count}"
  target_group_arn = "${aws_lb_target_group.kibana.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 80

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_listener" "kibana" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.kibana.arn}"
  }
}

# Security Group
resource "aws_security_group" "kibana" {
  name        = "${var.name}"
  description = "Allow inbound traffic to kibana"
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
