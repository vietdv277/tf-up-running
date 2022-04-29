provider "aws" {
  region = "ap-southeast-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_key_pair" "vietdv-iMac" {
  key_name = "vietdv-iMac-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCaw2/4a/DWOqMwcPdg5mHXBG0zkgtm2uFT6+mz9xD2SRwbC0TMPrn+eCOK9qy/VQhDX21fdJK1QoNvJ6V/TrKXXbtRFdDsyZR0WOITwZiMoPqs+/lxVgNDNUPFuwFpN9jfr/wph67lPJ35/AgjGlGyquWIV+VWRhqNIYkeogBY7nqfVSCMDCEdI4ol12PxPvBiAixaAid0MYbxMLpIxdY3ItvFnF+9SZWsdxRK7osIdVZph8DFzNUJZrIx+rzpW/IoKDFwrdYYF20R9KVXE7jdyo86x/AI31nxohsamKZCB7/VtZg7O6chjtYJqKfAkc/0KFCG8p5xLjS1MKlkU/OL1XMFHD0C2BjcZ+tNpbdSROjE83vzj7okFIeh2eE25U6wplX3FIr1RJZe5h+izZy5k1wG5qV79E33kXOp4ACNTZV8C4RWs5488O3ZoObMd7dz7LcK619QvyiUERfeBzozIG3E6eCYLV9TrN0m42HZlYb4zWl9Fd5LQnjavRmLXYEqj8BnBamVt2H1FntsyGOM2NT1XnMDVEELxfr9yuFVRZONLQykh65UvBW0LImbbqNTKaQl0NL15JhWCY1Seo+EOn9aOFyp/faYenW+MYD/JLBBzbGBxztwSMm+2IjP5vd2QWdRk00be1ReEXu0H+yhigND1G0n1hilQsTTE2D3xQ=="
}

resource "aws_launch_configuration" "webserver" {
  image_id = "ami-055d15d9cfddf7bd3"
  instance_type = "t2.micro"
  key_name = "vietdv-iMac-key"
  security_groups = [aws_security_group.sg-webserver.id]

  user_data = "${file("templates/apache2_install.sh")}"

  # Required when using a launch configuration with an ASG
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sg-webserver" {
  name = "tf-web-instance"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "webserver-asg" {
  launch_configuration = aws_launch_configuration.webserver.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 3

  tag {
    key     = "Name"
    value = "tf-asg-00"
    propagate_at_launch = true 
  } 
}

resource "aws_lb" "web-lb" {
  name = "tf-webserver-asg"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web-lb.arn
  port = 80
  protocol = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "tf-example-alb"

  # Allow inbound http requests
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name = "tf-asg-example"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.web-lb.dns_name
  description = "The domain name of the load blancer"
}
