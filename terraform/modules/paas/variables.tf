variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "zsch-ecs-cluster"
}

variable "task_family" {
  description = "Family of the ECS task definition"
  type        = string
  default     = "zsch-ecs-task"
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory (in MiB) for the ECS task"
  type        = string
  default     = "512"
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "demo-app"
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
  default     = "ghcr.io/karakean/text-to-speech-demo-app"
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of tasks for autoscaling"
  type        = number
  default     = 10
}

variable "min_capacity" {
  description = "Minimum number of tasks for autoscaling"
  type        = number
  default     = 2
}

variable "target_value_scale_out" {
  description = "Target value for scaling out"
  type        = number
  default     = 75.0
}

variable "target_value_scale_in" {
  description = "Target value for scaling in"
  type        = number
  default     = 20.0
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ECS service"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}
