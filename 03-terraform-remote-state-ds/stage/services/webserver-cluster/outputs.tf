output "alb_dns_name" {
  value = aws_lb.web-lb.dns_name
  description = "The domain name of the load blancer"
}