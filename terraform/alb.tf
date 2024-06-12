resource "aws_lb" "demo_alb" {
  name               = "zsch-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demo_alb_sg.id]
  subnets            = [aws_subnet.demo_subnet_1a.id, aws_subnet.demo_subnet_1b.id]
}

resource "aws_security_group" "demo_alb_sg" {
  name        = "zsch-alb-sg"
  description = "SG for external ALB"
  vpc_id      = aws_vpc.demo_vpc.id

  tags = {
    Name = "zsch-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo_alb_sg_allow_ingress_traffic_ipv4" {
  security_group_id = aws_security_group.demo_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "demo_alb_sg_allow_ingress_traffic_ipv6" {
  security_group_id = aws_security_group.demo_alb_sg.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "demo_alb_sg_allow_all_egress_traffic_ipv4" {
  security_group_id = aws_security_group.demo_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "demo_alb_sg_allow_all_egress_traffic_ipv6" {
  security_group_id = aws_security_group.demo_alb_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_lb_listener" "demo_alb_listener" {
    load_balancer_arn = aws_lb.demo_alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.demo_alb_app_tg.arn
    }
}

resource "aws_lb_target_group" "demo_alb_app_tg" {
  name     = "zsch-alb-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo_vpc.id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.demo_alb.dns_name
}
