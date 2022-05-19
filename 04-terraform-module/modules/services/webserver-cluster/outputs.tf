output "alb_dns_name" {
  value = aws_lb.web-lb.dns_name
  description = "The domain name of the load blancer"
}

output "asg_name" {
  value = aws_autoscaling_group.webserver-asg.name
  description = "The name of Auto Scaling Group"
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
  description = "The ID of ALB Security Group"
}