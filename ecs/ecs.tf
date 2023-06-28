resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "meet-ecs-cluster"
  tags = {
    Name        = "meet-ecs"
    Environment = "stage"
    value = "enabled"
  }
}

resource "aws_lb_listener" "mtc_lb_listener" {
  load_balancer_arn = var.aws_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = var.aws_lb_target_group.arn
  }
}


resource "aws_ecs_task_definition" "task-definition" {
  family = "meet-task-defination"
  container_definitions = jsonencode([
    {
      name      = "meet-nginx-ecs-container"
      image     = "nginx"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      cpu : 256,
      memory : 512,
    }
  ])

 requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name        = "meet-ecs-td"
    Environment = "stage"
  }
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "meet-ecs-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.task-definition.arn #"${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = var.public_subnets
    assign_public_ip = true
    security_groups = [
      var.public_sg
    ]
  }

  load_balancer {
    target_group_arn = var.aws_lb_target_group.arn
    container_name   = "meet-nginx-ecs-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.mtc_lb_listener]
}