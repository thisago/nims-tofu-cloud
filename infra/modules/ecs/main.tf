resource "aws_ecs_cluster" "nims_tofu_cloud_cluster" {
  name = "nims_tofu_cloud_cluster"
}

resource "aws_ecs_task_definition" "nims_tofu_cloud_task" {
  family                   = "nims_tofu_cloud_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "128"
  memory                   = "128"

  container_definitions = jsonencode([
    {
      name      = "nims_tofu_cloud_container",
      image     = "ghcr.io/thisago/thisago/nims-tofu-cloud:latest"
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

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }
}
resource "aws_lb" "nims_tofu_cloud_alb" {
  name               = "nims-tofu-cloud-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  tags = {
    Name    = "nims_tofu_cloud_alb"
  }
}

resource "aws_lb_target_group" "nims_tofu_cloud_tg" {
  name     = "nims-tofu-cloud-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name    = "nims_tofu_cloud_tg"
  }
}

resource "aws_lb_listener" "nims_tofu_cloud_listener" {
  load_balancer_arn = aws_lb.nims_tofu_cloud_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nims_tofu_cloud_tg.arn
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nims_tofu_cloud_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "nims_tofu_cloud_tg_attachment" {
  target_group_arn = aws_lb_target_group.nims_tofu_cloud_tg.arn
  target_id        = aws_ecs_service.nims_tofu_cloud_service.id
  port             = 5000
}
