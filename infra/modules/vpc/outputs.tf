output "vpc_id" {
  value = aws_vpc.nims_tofu_cloud_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.nims_tofu_cloud_subnet[*].id
}
