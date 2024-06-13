# 2. PaaS (& CaaS & serverless)

resource "aws_ecs_cluster" "demo_ecs_cluster" {
  name = "zsch-ecs-cluster"
}

resource "aws_ecs_task_definition" "demo_task" {
  family                   = "zsch-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "demo-app"
      image = "ghcr.io/karakean/text-to-speech-demo-app"
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "demo_ecs_service" {
  name            = "zsch-ecs-service"
  cluster         = aws_ecs_cluster.demo_ecs_cluster.id
  task_definition = aws_ecs_task_definition.demo_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.demo_subnet_1a.id, aws_subnet.demo_subnet_1b.id]
    security_groups = [aws_security_group.demo_app_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.demo_alb_app_tg.arn
    container_name   = "demo-app"
    container_port   = 8080
  }
}

resource "aws_appautoscaling_target" "demo_scaling_target" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.demo_ecs_cluster.name}/${aws_ecs_service.demo_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "demo_scaling_out_policy" {
  name               = "scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.demo_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.demo_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.demo_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 75.0
  }
}

resource "aws_appautoscaling_policy" "demo_scaling_in_policy" {
  name               = "scale-in"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.demo_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.demo_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.demo_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 20.0
  }
}
