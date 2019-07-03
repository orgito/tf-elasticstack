variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
}

variable "name" {
  description = "Cluster name"
}

variable "vpc" {
  description = "VPC ID where to deploy the instances"
}


variable "elk_version" {
  description = "Logstash version to install (6.X.Y). If blank or 'latest' install the latest version"
  default = "latest"
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

variable "pipeline" {
  description = "Initial Logstash pipeline"
}

variable "load_balancer" {
  description = "Load Balancer arn"
}

variable "ssh_key_pair" {
  description = "EC2 SSH key name to manage the instances"
}
