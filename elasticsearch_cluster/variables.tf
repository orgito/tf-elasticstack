variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
}

variable "name" {
  description = "Will be concatenated with namespace and prefix to set the cluster name"
}

variable "elk_version" {
  description = "Elasticsearch version to install (6.X.Y). If blank or 'latest' install the latest version"
  default = "latest"
}

variable "vpc" {
  description = "VPC ID where to deploy the instances"
}

variable "subnets" {
  description = "Subnet IDs where to deploy the instances. At least 2 subnets in distinct availability zones."
  type  = "list"
}

variable "ami" {
  description = "Amazon Machine Image ID"
}

variable "type" {
  description = "EC2 Instance Type"
}
variable "instance_count" {
  description = "Number of nodes in the cluster"
}
variable "storage_size" {
  description = "Data volume size (GB)"
}

variable "ssh_key_pair" {
  description = "EC2 SSH key name to manage the instances"
}

variable "load_balancer" {
  description = "Load Balancer arn"
}
