output "ecs_cluster_id" {
  value = aws_ecs_cluster.nims_tofu_cloud_cluster.id
}

output "alb_dns_name" {
  value = aws_lb.nims_tofu_cloud_alb.dns_name
  description = "The public DNS name of the ALB"
}
