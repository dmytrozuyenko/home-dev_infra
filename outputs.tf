output "load_balancer_ip" {
  value = aws_lb.home.dns_name
}
