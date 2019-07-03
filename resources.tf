module "elasticsearch" {
  source = "./elasticsearch_cluster"

  ami            = "${data.aws_ami.selected.id}"
  elk_version    = "${var.elk_version}"
  instance_count = "${var.es_node_count}"
  name           = "${lower("${var.namespace}${var.stage}_elasticsearch_${var.cluster_name}")}"
  stage          = "${var.stage}"
  load_balancer  = "${module.alb.arn}"
  ssh_key_pair   = "${var.ssh_key_pair}"
  storage_size   = "${var.es_storage_size}"
  subnets        = "${var.subnets}"
  type           = "${var.es_instance_type}"
  vpc            = "${data.aws_vpc.vpc.id}"
}

module "logstash" {
  source = "./logstash_cluster"

  ami            = "${data.aws_ami.selected.id}"
  elk_version    = "${var.elk_version}"
  instance_count = "${var.logstash_node_count}"
  name           = "${lower("${var.namespace}${var.stage}_logstash")}"
  stage          = "${var.stage}"
  load_balancer  = "${aws_lb.nlb.arn}"
  ssh_key_pair   = "${var.ssh_key_pair}"
  subnets        = "${var.subnets}"
  type           = "${var.logstash_instance_type}"
  vpc            = "${data.aws_vpc.vpc.id}"
  pipeline       = "${data.template_file.pipeline.rendered}"
}

module "kibana" {
  source = "./kibana_cluster"

  ami               = "${data.aws_ami.selected.id}"
  elk_version       = "${var.elk_version}"
  elasticsearch_url = "http://${module.alb.dns_name}:9200"
  instance_count    = "${var.kibana_node_count}"
  name              = "${lower("${var.namespace}${var.stage}_kibana")}"
  stage             = "${var.stage}"
  load_balancer     = "${module.alb.arn}"
  ssh_key_pair      = "${var.ssh_key_pair}"
  subnets           = "${var.subnets}"
  type              = "${var.kibana_instance_type}"
  vpc               = "${data.aws_vpc.vpc.id}"
}

module "cerebro" {
  source = "./cerebro"

  ami               = "${data.aws_ami.selected.id}"
  cerebro_version   = "${var.cerebro_version}"
  elasticsearch_url = "http://${module.alb.dns_name}:9200"
  es_cluster_name   = "${lower("${var.namespace}${var.stage}_elasticsearch_${var.cluster_name}")}"
  name              = "${lower("${var.namespace}${var.stage}_cerebro")}"
  stage             = "${var.stage}"
  ssh_key_pair      = "${var.ssh_key_pair}"
  vpc               = "${data.aws_vpc.vpc.id}"
  subnet            = "${var.subnets[0]}"
  type              = "${var.cerebro_instance_type}"
}

module "alb" {
  source = "./load_balancer"

  name            = "${lower("${var.namespace}${var.stage}-alb")}"
  stage           = "${var.stage}"
  subnets         = "${var.subnets}"
  vpc             = "${data.aws_vpc.vpc.id}"
}

resource "aws_lb" "nlb" {
  name               = "${local.safe_prefix}-nlb"
  internal           = true
  subnets            = ["${var.subnets}"]
  load_balancer_type = "network"

  enable_cross_zone_load_balancing = true

  tags = {
    Name        = "${local.safe_prefix}-nlb"
    Environment = "${var.stage}"
    Provision   = "terraform"
    Inventory   = "ansible"
  }
}
