resource "aws_ecs_cluster" "demo_ecs_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "demo_task" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.container_image
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
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
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

resource "aws_appautoscaling_target" "demo_scaling_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
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
    target_value = var.target_value_scale_out
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
    target_value = var.target_value_scale_in
  }
}
