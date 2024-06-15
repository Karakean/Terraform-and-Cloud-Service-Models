terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "initial_infrastructure" {
  source = "./modules/initial_infrastructure"
  
  vpc_cidr_block        = "10.0.0.0/16"
  subnet_1a_cidr        = "10.0.0.0/24"
  subnet_1b_cidr        = "10.0.1.0/24"
  app_port              = 8080
  alb_target_group_protocol = "HTTP"
  alb_hc_interval       = 30
  alb_hc_path           = "/"
  alb_hc_protocol       = "HTTP"
  alb_hc_timeout        = 5
  alb_hc_healthy_threshold = 3
  alb_hc_unhealthy_threshold = 3
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.initial_infrastructure.alb_dns_name
}

module "iaas" {
  source = "./modules/iaas"
  
  ami               = "ami-00cf59bc9978eb266"
  instance_type     = "t2.micro"
  instance_count    = 2
  subnet_ids        = [module.initial_infrastructure.subnet_1a_id, module.initial_infrastructure.subnet_1b_id]
  security_group_id = module.initial_infrastructure.app_sg_id
  target_group_arn  = module.initial_infrastructure.alb_target_group_arn
  app_port          = module.initial_infrastructure.app_port
  docker_image      = "ghcr.io/karakean/text-to-speech-demo-app"
}

module "paas" {
  source = "./modules/paas"
  
  cluster_name           = "zsch-ecs-cluster"
  task_family            = "zsch-ecs-task"
  task_cpu               = "256"
  task_memory            = "512"
  container_name         = "demo-app"
  container_image        = "ghcr.io/karakean/text-to-speech-demo-app"
  container_port         = module.initial_infrastructure.app_port
  desired_count          = 2
  max_capacity           = 5
  min_capacity           = 2
  target_value_scale_out = 75.0
  target_value_scale_in  = 20.0
  subnet_ids             = [module.initial_infrastructure.subnet_1a_id, module.initial_infrastructure.subnet_1b_id]
  security_group_id      = module.initial_infrastructure.app_sg_id
  target_group_arn       = module.initial_infrastructure.alb_target_group_arn
}
