provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

// Use existing VPC and subnets
data "aws_vpc" "default" {}
data "aws_subnets" "public" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_security_group" "svc" {
  name   = "nims-tofu"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "nims-tofu-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

// IAM role policy attachment for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

// Main ECS resources for NIMS Tofu Cloud
resource "aws_ecs_cluster" "default" {
  name = "nims-tofu-cluster"
}

resource "aws_ecs_task_definition" "tofu" {
  family                   = "nims-tofu"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "tofu"
      image     = var.image
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      environment = [
        {
          name  = "SECRET"
          value = var.secret
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/nims-tofu"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "tofu"
        }
      }
    }
  ])
}

// IAM role for ECS task execution
resource "aws_ecs_service" "tofu" {
  name            = "nims-tofu"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.tofu.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [aws_security_group.svc.id]
    assign_public_ip = true
  }

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200
}
