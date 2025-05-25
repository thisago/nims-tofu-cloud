resource "aws_vpc" "nims_tofu_cloud_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name    = "nims_tofu_cloud_vpc"
  }
}

resource "aws_subnet" "nims_tofu_cloud_subnet" {
  count             = 1
  vpc_id            = aws_vpc.nims_tofu_cloud_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "nims_tofu_cloud_subnet"
  }
}

resource "aws_internet_gateway" "nims_tofu_cloud_igw" {
  vpc_id = aws_vpc.nims_tofu_cloud_vpc.id
  tags = {
    Name = "nims_tofu_cloud_igw"
  }
}

resource "aws_route_table" "nims_tofu_cloud_route_table" {
  vpc_id = aws_vpc.nims_tofu_cloud_vpc.id
  tags = {
    Name = "nims_tofu_cloud_route_table"
  }
}

resource "aws_route" "nims_tofu_cloud_route" {
  route_table_id         = aws_route_table.nims_tofu_cloud_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nims_tofu_cloud_igw.id
}

resource "aws_route_table_association" "nims_tofu_cloud_route_table_association" {
  subnet_id      = aws_subnet.nims_tofu_cloud_subnet[0].id
  route_table_id = aws_route_table.nims_tofu_cloud_route_table.id
}

data "aws_availability_zones" "available" {}
