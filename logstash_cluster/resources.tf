module "cluster" {
  source = "../cluster"

  ami            = "${var.ami}"
  groups         = ["${aws_security_group.logstash.id}"]
  instance_count = "${var.instance_count}"
  name           = "${var.name}"
  stage          = "${var.stage}"
  role           = "logstash"
  ssh_key_pair   = "${var.ssh_key_pair}"
  subnets        = "${var.subnets}"
  type           = "${var.type}"
  user_data      = "${data.template_cloudinit_config.provision.rendered}"
  vpc            = "${var.vpc}"
}

resource "aws_lb_target_group" "logstash-beats" {
  name     = "${local.safe_name}-beats"
  port     = 5044
  protocol = "TCP"
  vpc_id   = "${var.vpc}"
}

resource "aws_lb_target_group_attachment" "logstash-beats" {
  target_group_arn = "${aws_lb_target_group.logstash-beats.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 5044

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_target_group" "logstash-winston" {
  name     = "${local.safe_name}-winston"
  port     = 28777
  protocol = "TCP"
  vpc_id   = "${var.vpc}"
}

resource "aws_lb_target_group_attachment" "logstash-winston" {
  target_group_arn = "${aws_lb_target_group.logstash-winston.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 28777

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_target_group" "logstash-input1" {
  name     = "${local.safe_name}-input1"
  port     = 6001
  protocol = "TCP"
  vpc_id   = "${var.vpc}"
}

resource "aws_lb_target_group_attachment" "logstash-input1" {
  target_group_arn = "${aws_lb_target_group.logstash-input1.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 6001

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_target_group" "logstash-input2" {
  name     = "${local.safe_name}-input2"
  port     = 6002
  protocol = "TCP"
  vpc_id   = "${var.vpc}"
}

resource "aws_lb_target_group_attachment" "logstash-input2" {
  target_group_arn = "${aws_lb_target_group.logstash-input2.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 6002

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_target_group" "logstash-input3" {
  name     = "${local.safe_name}-input3"
  port     = 6003
  protocol = "TCP"
  vpc_id   = "${var.vpc}"
}

resource "aws_lb_target_group_attachment" "logstash-input3" {
  target_group_arn = "${aws_lb_target_group.logstash-input3.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 6003

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_target_group" "logstash-input4" {
  name     = "${local.safe_name}-input4"
  port     = 6004
  protocol = "TCP"
  vpc_id   = "${var.vpc}"
}

resource "aws_lb_target_group_attachment" "logstash-input4" {
  target_group_arn = "${aws_lb_target_group.logstash-input4.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 6004

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_target_group" "logstash-input5" {
  name     = "${local.safe_name}-input5"
  port     = 6005
  protocol = "TCP"
  vpc_id   = "${var.vpc}"
}

resource "aws_lb_target_group_attachment" "logstash-input5" {
  target_group_arn = "${aws_lb_target_group.logstash-input5.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 6005

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_listener" "logstash-beats" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 5044
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logstash-beats.arn}"
  }
}

resource "aws_lb_listener" "logstash-winston" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 28777
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logstash-winston.arn}"
  }
}

resource "aws_lb_listener" "logstash-input1" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 6001
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logstash-input1.arn}"
  }
}

resource "aws_lb_listener" "logstash-input2" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 6002
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logstash-input2.arn}"
  }
}

resource "aws_lb_listener" "logstash-input3" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 6003
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logstash-input3.arn}"
  }
}

resource "aws_lb_listener" "logstash-input4" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 6004
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logstash-input4.arn}"
  }
}

resource "aws_lb_listener" "logstash-input5" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 6005
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logstash-input5.arn}"
  }
}

# Security Group
resource "aws_security_group" "logstash" {
  name        = "${var.name}"
  description = "Allow inbound traffic to Logstash"
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
    description = "BEATS input plugin"
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom TCP input plugin (28777)"
    from_port   = 28777
    to_port     = 28777
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom TCP Input Plugins (6001-6005)"
    from_port   = 6001
    to_port     = 6005
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Syslog"
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Syslog"
    from_port   = 514
    to_port     = 514
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
