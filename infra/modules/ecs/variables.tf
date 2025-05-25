variable "log_group_name" {
  description = "The name of the CloudWatch log group"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "secret" {
  description = "The secret environment variable for the application"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}

variable "security_group_id" {
  description = "The ID of the security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
