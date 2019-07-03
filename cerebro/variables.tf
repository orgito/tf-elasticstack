variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
}

variable "name" {
  description = "Cerebrom instance name"
}

variable "cerebro_version" {
  description = "Cerebro version to install"
  default = "0.8.1"
}

variable "elasticsearch_url" {
  description = "The URL of the Elasticsearch instance to use for all your queries"
  default = "http://localhost:9200"
}

variable "es_cluster_name" {
  description = "Elasticsearch cluster name"
  default = "elasticsearch"
}


variable "subnet" {
  description = "Subnet ID where to deploy the instance."
}

variable "ami" {
  description = "Amazon Machine Image ID"
}

variable "type" {
  description = "EC2 Instance Type"
  default = "t3.small"
}

variable "vpc" {
  description = "VPC ID where to deploy the instances"
}

variable "ssh_key_pair" {
  description = "EC2 SSH key name to manage the instances"
}

