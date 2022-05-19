data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "ap-southeast-1"
   }
}

locals {
  ssh_port     = 22
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  all_ips      = ["0.0.0.0/0"]
}

resource "aws_launch_configuration" "webserver" {
  image_id = "ami-055d15d9cfddf7bd3"
  instance_type = var.instance_type
  key_name = var.ssh_key_name
  security_groups = [aws_security_group.web-sg.id]

  user_data = templatefile("${path.module}/templates/apache2_install.sh", {
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  })

  # Required when using a launch configuration with an ASG
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "web-sg" {
  name = "${var.cluster_name}-web-sg"
}

resource "aws_security_group_rule" "web_allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.web-sg.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = "tcp"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "web_allow_ssh_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.web-sg.id

  from_port   = local.ssh_port
  to_port     = local.ssh_port
  protocol    = "tcp"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "web_allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.web-sg.id

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_autoscaling_group" "webserver-asg" {
  launch_configuration = aws_launch_configuration.webserver.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true 
  } 
}

resource "aws_lb" "web-lb" {
  name               = "tf-webserver-asg"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web-lb.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "lb_allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = "tcp"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "lb_allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.alb.id

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_lb_target_group" "asg" {
  name     = var.cluster_name
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

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

