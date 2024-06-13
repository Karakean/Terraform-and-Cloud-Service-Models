# 1. IaaS

resource "aws_network_interface" "demo_eni" {
  subnet_id = element([aws_subnet.demo_subnet_1a.id, aws_subnet.demo_subnet_1b.id], count.index)
  security_groups = [aws_security_group.demo_app_sg.id]
  count = 2

  tags = {
    Name = "zsch-primary-eni-${count.index}"
  }
}

resource "aws_instance" "demo_ec2" {
  ami = "ami-00cf59bc9978eb266"
  instance_type = "t2.micro"
  count = 2

  network_interface {
    network_interface_id = aws_network_interface.demo_eni[count.index].id
    device_index = 0
  }

  tags = {
    Name = "zsch-ec2-${count.index}"
  }

  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum -y install docker
            sudo service docker start
            sudo docker run -d -p 8080:8080 --name demo-app ghcr.io/karakean/text-to-speech-demo-app
            EOF
}

resource "aws_lb_target_group_attachment" "demo_tg_attachment" {
  target_group_arn = aws_lb_target_group.demo_alb_app_tg.arn
  target_id        = aws_instance.demo_ec2[0].private_ip
  port             = 8080
}

resource "aws_lb_target_group_attachment" "demo_tg_attachment_2" {
  target_group_arn = aws_lb_target_group.demo_alb_app_tg.arn
  target_id        = aws_instance.demo_ec2[1].private_ip
  port             = 8080
}
