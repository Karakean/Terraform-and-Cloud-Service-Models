variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1a_cidr" {
  description = "CIDR block for subnet 1a"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet_1b_cidr" {
  description = "CIDR block for subnet 1b"
  type        = string
  default     = "10.0.1.0/24"
}

variable "alb_target_group_protocol" {
  description = "Protocol for the ALB target group"
  type        = string
  default     = "HTTP"
}

variable "alb_hc_interval" {
  description = "Health check interval for the ALB target group"
  type        = number
  default     = 30
}

variable "alb_hc_path" {
  description = "Health check path for the ALB target group"
  type        = string
  default     = "/"
}

variable "alb_hc_protocol" {
  description = "Health check protocol for the ALB target group"
  type        = string
  default     = "HTTP"
}

variable "alb_hc_timeout" {
  description = "Health check timeout for the ALB target group"
  type        = number
  default     = 5
}

variable "alb_hc_healthy_threshold" {
  description = "Health check healthy threshold for the ALB target group"
  type        = number
  default     = 2
}

variable "alb_hc_unhealthy_threshold" {
  description = "Health check unhealthy threshold for the ALB target group"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Ingress port for the application security group"
  type        = number
  default     = 8080
}
