resource "aws_security_group" "demo_app_sg" {
  name        = "zsch-app-sg"
  description = "SG for our app"
  vpc_id      = aws_vpc.demo_vpc.id

  tags = {
    Name = "zsch-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo_app_sg_allow_traffic_from_alb" {
  security_group_id             = aws_security_group.demo_app_sg.id
  referenced_security_group_id  = aws_security_group.demo_alb_sg.id
  from_port                     = var.app_port
  ip_protocol                   = "tcp"
  to_port                       = var.app_port
}

resource "aws_vpc_security_group_egress_rule" "demo_app_sg_allow_all_egress_traffic_ipv4" {
  security_group_id = aws_security_group.demo_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "demo_app_sg_allow_all_egress_traffic_ipv6" {
  security_group_id = aws_security_group.demo_app_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
