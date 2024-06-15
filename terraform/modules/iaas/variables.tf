variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-00cf59bc9978eb266"
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 8080
}

variable "docker_image" {
  description = "Docker image to run on the EC2 instances"
  type        = string
  default     = "ghcr.io/karakean/text-to-speech-demo-app"
}
