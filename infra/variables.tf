variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secret" {
  description = "The secret environment variable for the application"
  type        = string
}

variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "image" {
  description = "Docker image for the ECS task"
  type        = string
  default     = "ghcr.io/thisago/thisago/nims-tofu-cloud:v0.2.0"
}
