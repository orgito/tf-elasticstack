variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "namespace" {
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'co' or 'company'"
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
}

variable "cluster_name" {
  description = "Elasticsearch Cluster Name. Will be concatenated with namespace and prefix to set Elasticsearch cluster.name variable"
}

variable "region" { }

variable "vpc" {
  description = "VPC ID where to deploy the instances"
}

variable "subnets" {
  description = "Subnet IDs where to deploy the instances. At least 2 subnets in distinct availability zones."
  type        = "list"
}

variable "es_instance_type" {
  description = "Elasticsearch Node instance type"
}

variable "es_node_count" {
  description = "Number of Elasticsearch Nodes in the cluster"
  default     = 4
}

variable "es_storage_size" {
  description = "Elasticsearch Node data volume size (GB)"
  default     = 100
}

variable "kibana_instance_type" {
  description = "Kibana instance type"
}

variable "kibana_node_count" {
  description = "Number of Kibana Nodes in the cluster"
  default     = 2
}

variable "logstash_instance_type" {
  description = "Logstash instance type"
}

variable "logstash_node_count" {
  description = "Number of Logstash Nodes in the cluster"
  default     = 2
}

variable "ssh_key_pair" {
  description = "EC2 SSH key name to manage the instances"
}

variable "elk_version" {
  description = "Elastic Stack version to install (6.X.Y). If blank or 'latest' install the latest version"
  default = "latest"
}

variable "cerebro_instance_type" {
  description = "Cerebro instance type"
}

variable "cerebro_version" {
  description = "Cerebro version to install"
  default = "0.8.1"
}
