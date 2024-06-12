# 0. Initial setup

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "zsch-vpc"
  }
}

resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_route_table" "demo_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }
}

resource "aws_route_table_association" "demo_route_table_association_1a" {
  subnet_id      = aws_subnet.demo_subnet_1a.id
  route_table_id = aws_route_table.demo_route_table.id
}

resource "aws_route_table_association" "demo_route_table_association_1b" {
  subnet_id      = aws_subnet.demo_subnet_1b.id
  route_table_id = aws_route_table.demo_route_table.id
}

resource "aws_subnet" "demo_subnet_1a" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "zsch-subnet-1a"
  }
}

resource "aws_subnet" "demo_subnet_1b" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "zsch-subnet-1b"
  }
}

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

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.demo_alb.dns_name
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

resource "aws_lb_listener" "demo_alb_listener" {
    load_balancer_arn = aws_lb.demo_alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.demo_alb_app_tg.arn
    }
}

resource "aws_security_group" "demo_app_sg" {
  name        = "zsch-app-sg"
  description = "SG for our app"
  vpc_id      = aws_vpc.demo_vpc.id

  tags = {
    Name = "zsch-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo_app_sg_allow_traffic_from_alb" {
  security_group_id = aws_security_group.demo_app_sg.id
  referenced_security_group_id = aws_security_group.demo_alb_sg.id
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
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


# 1. IaaS

# resource "aws_network_interface" "demo_eni" {
#   subnet_id = aws_subnet.demo_subnet_1a.id
#   security_groups = [aws_security_group.demo_app_sg.id]
#   count = 2

#   tags = {
#     Name = "zsch-primary-eni-${count.index}"
#   }
# }

# resource "aws_instance" "demo_ec2" {
#   ami = "ami-00cf59bc9978eb266"
#   instance_type = "t2.micro"
#   count = 2

#   network_interface {
#     network_interface_id = aws_network_interface.demo_eni[count.index].id
#     device_index = 0
#   }

#   tags = {
#     Name = "zsch-ec2-${count.index}"
#   }

#   user_data = <<-EOF
#             #!/bin/bash
#             sudo yum update -y
#             sudo yum -y install docker
#             sudo service docker start
#             sudo docker run -d -p 8080:8080 --name demo-app ghcr.io/karakean/text-to-speech-demo-app
#             EOF
# }

# resource "aws_lb_target_group_attachment" "demo_tg_attachment" {
#   target_group_arn = aws_lb_target_group.demo_alb_app_tg.arn
#   target_id        = aws_instance.demo_ec2[0].private_ip
#   port             = 8080
# }

# resource "aws_lb_target_group_attachment" "demo_tg_attachment_2" {
#   target_group_arn = aws_lb_target_group.demo_alb_app_tg.arn
#   target_id        = aws_instance.demo_ec2[1].private_ip
#   port             = 8080
# }


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

# 3. SaaS