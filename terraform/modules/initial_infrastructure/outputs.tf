output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.demo_alb.dns_name
}

output "subnet_1a_id" {
  description = "The ID of the subnet in availability zone 1a"
  value       = aws_subnet.demo_subnet_1a.id
}

output "subnet_1b_id" {
  description = "The ID of the subnet in availability zone 1b"
  value       = aws_subnet.demo_subnet_1b.id
}

output "app_sg_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.demo_app_sg.id
}

output "alb_target_group_arn" {
  description = "The ARN of the ALB target group"
  value       = aws_lb_target_group.demo_alb_app_tg.arn
}

output "app_port" {
  description = "The ingress port for the application"
  value       = var.app_port
}
