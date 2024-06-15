resource "aws_network_interface" "demo_eni" {
  count = var.instance_count

  subnet_id = element(var.subnet_ids, count.index % length(var.subnet_ids))
  security_groups = [var.security_group_id]

  tags = {
    Name = "zsch-primary-eni-${count.index}"
  }
}

resource "aws_instance" "demo_ec2" {
  count = var.instance_count

  ami           = var.ami
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.demo_eni[count.index].id
    device_index         = 0
  }

  tags = {
    Name = "zsch-ec2-${count.index}"
  }

  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum -y install docker
            sudo service docker start
            sudo docker run -d -p ${var.app_port}:${var.app_port} --name demo-app ${var.docker_image}
            EOF
}

resource "aws_lb_target_group_attachment" "demo_tg_attachment" {
  count = var.instance_count

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.demo_ec2[count.index].private_ip
  port             = var.app_port
}
