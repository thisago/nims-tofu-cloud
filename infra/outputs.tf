output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "subnet_ids" {
  value       = module.vpc.subnet_ids
  description = "The IDs of the subnets"
}

output "security_group_id" {
  value       = module.security_group.security_group_id
  description = "The ID of the security group"
}


output "ecs_cluster_id" {
  value       = module.ecs.ecs_cluster_id
  description = "The ID of the ECS cluster"
}

output "ecs_service_public_ip" {
  value       = module.ecs.ecs_service_public_ip
  description = "The public IP of the ECS service"
}
