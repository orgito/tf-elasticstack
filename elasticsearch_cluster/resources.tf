module "cluster" {
  source = "../cluster"

  ami            = "${var.ami}"
  groups         = ["${aws_security_group.elasticsearch.id}"]
  iam_profile    = "${aws_iam_instance_profile.elasticsearch.name}"
  instance_count = "${var.instance_count}"
  name           = "${var.name}"
  stage          = "${var.stage}"
  role           = "elasticsearch"
  ssh_key_pair   = "${var.ssh_key_pair}"
  storage_size   = "${var.storage_size}"
  subnets        = "${var.subnets}"
  type           = "${var.type}"
  user_data      = "${data.template_cloudinit_config.provision.rendered}"
  vpc            = "${var.vpc}"
}

resource "aws_lb_target_group" "elasticsearch" {
  name     = "${local.safe_name}"
  port     = 9200
  protocol = "HTTP"
  vpc_id   = "${var.vpc}"

  health_check {
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "elasticsearch" {
  count            = "${var.instance_count}"
  target_group_arn = "${aws_lb_target_group.elasticsearch.arn}"
  target_id        = "${element(module.cluster.instance_ids, count.index)}"
  port             = 9200

  lifecycle {
    ignore_changes = true #ISSUE 253
  }
}

resource "aws_lb_listener" "elasticsearch" {
  load_balancer_arn = "${var.load_balancer}"
  port              = 9200
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.elasticsearch.arn}"
  }
}

resource "aws_security_group" "elasticsearch" {
  name        = "${var.name}"
  description = "Allow inbound traffic to the Elasticsearch Cluster"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    description = "Elasticsearch REST API"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_iam_role" "elasticsearch" {
  name = "${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "elasticsearch" {
  statement {
    sid = "1"

    actions = [
      "ec2:DescribeInstances",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "elasticsearch" {
  name   = "${var.name}"
  policy = "${data.aws_iam_policy_document.elasticsearch.json}"
}

resource "aws_iam_role_policy_attachment" "elasticsearch_policy" {
  role       = "${aws_iam_role.elasticsearch.name}"
  policy_arn = "${aws_iam_policy.elasticsearch.arn}"
}

resource "aws_iam_instance_profile" "elasticsearch" {
  name = "${var.name}"
  role = "${aws_iam_role.elasticsearch.name}"
}
