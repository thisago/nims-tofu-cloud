resource "aws_security_group" "nims_tofu_cloud_sg" {
  name        = "nims_tofu_cloud_sg"
  description = "Allow internal communication"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "nims_tofu_cloud_sg"
  }
}
