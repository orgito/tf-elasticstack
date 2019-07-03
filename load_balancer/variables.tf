variable "name" {
  description = "Load Balancer name"
}

variable "type" {
  description = "Load Balancer type"
  default = "application"
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
}

variable "vpc" {
  description = "VPC ID where to deploy the instances"
}

variable "subnets" {
  description = "Subnet IDs where to deploy the instances. At least 2 subnets in distinct availability zones."
  type        = "list"
}
