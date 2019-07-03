variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
}

variable "name" {
  description = "Cluster name"
}

variable "role" {
  description = "Cluster role"
  default = "node"
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
  description = "Data volume size (GB) <optional>"
  default = 0
}

variable "groups" {
  description = "List of security group to associate with the instances"
  type  = "list"
}

variable "user_data" {
  description = "The user data to provide when launching the instances <optional>"
  default = ""
}

variable "iam_profile" {
  description = "IAM Intance Profile <optional>"
  default  = ""
}

variable "ssh_key_pair" {
  description = "EC2 SSH key name to manage the instances"
}

