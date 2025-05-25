resource "aws_ecs_cluster" "nims_tofu_cloud_cluster" {
  name = "nims_tofu_cloud_cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ecs_task_execution_role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "nims_tofu_cloud_task" {
  family                   = "nims_tofu_cloud_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "nims_tofu_cloud_container",
      image     = "ghcr.io/thisago/thisago/nims-tofu-cloud:v0.2.0"
      cpu       = 128
      memory    = 128
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      },
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ],
      environment = [
        {
          name  = "SECRET"
          value = var.secret
        }
      ]
    }
  ])
}

resource "aws_cloudwatch_log_group" "nims_tofu_cloud_log_group" {
  name              = var.log_group_name
  retention_in_days = 5
  tags = {
    Name    = "nims_tofu_cloud_log_group"
  }
}

resource "aws_ecs_service" "nims_tofu_cloud_service" {
  name            = "nims_tofu_cloud_service"
  cluster         = aws_ecs_cluster.nims_tofu_cloud_cluster.id
  task_definition = aws_ecs_task_definition.nims_tofu_cloud_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
}
