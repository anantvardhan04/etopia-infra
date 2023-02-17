resource "aws_security_group" "etopia-ext-alb-sg" {
  vpc_id = aws_vpc.etopia_vpc.id
  name = format("etopia-%s-ext-alb-sg", var.environment)
  tags = {
    Name = format("etopia-%s-ext-alb-sg", var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "etopia-sg-ext-in80-01" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.etopia-ext-alb-sg.id
  description = "Allow all on port 80 (It is redirected to 443)"
}

# resource "aws_security_group_rule" "etopia-sg-ext-allow-internet" {
#   type = "ingress"
#   from_port = 443
#   to_port = 443
#   protocol = "tcp"
#   cidr_blocks = [
#     "0.0.0.0/0"
#   ]
#   security_group_id = aws_security_group.etopia-ext-alb-sg.id
#   description = "Allow all on port 443"
# }

resource "aws_security_group_rule" "etopia-sg-ext-eg" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.etopia-ext-alb-sg.id
}

resource "aws_alb" "etopia-ext-alb" {
  name = format("etopia-%s-ext-lb", var.environment)
  internal = false
  load_balancer_type = "application"
  subnets = [aws_subnet.etopia_public_subnet_1.id, aws_subnet.etopia_public_subnet_2.id]
  security_groups = [aws_security_group.etopia-ext-alb-sg.id]
  enable_cross_zone_load_balancing = true
  enable_deletion_protection = true
  tags = {
    Name = format("etopia-%s-ext-lb", var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
}

resource "aws_alb_listener" "etopia-ext-alb-listener-80" {
  load_balancer_arn = aws_alb.etopia-ext-alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<html><head><title>404 Not Found</title></head><body><center><h1>404 Not Found</h1></center><hr><center>nginx</center></body></html>"
      status_code = "404"
    }
  }
}

# resource "aws_alb_listener" "etopia-ext-alb-listener-443" {
#   load_balancer_arn =  aws_alb.etopia-ext-alb.arn
#   port = "443"
#   protocol = "HTTPS"
#   ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
#   certificate_arn = var.brand_config["external_SSL_certificate_arn"]
#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/html"
#       message_body = "<html><head><title>404 Not Found</title></head><body><center><h1>404 Not Found</h1></center><hr><center>nginx</center></body></html>"
#       status_code = "404"
#     }
#   }
# }

resource "aws_alb_target_group" "etopia-ext-alb-tg-80" {
  name = format("etopia-%s-e80", var.environment)
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.etopia_vpc.id
  health_check {
    interval = 60
    port = "80"
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 10
    protocol = "HTTP"
    matcher = "200"
  }
  tags = {
    Name = format("etopia-%s-e443", var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
}

resource "aws_alb_listener_rule" "ext-alb-80" {
  listener_arn = aws_alb_listener.etopia-ext-alb-listener-80.arn
  priority = 10
  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.etopia-ext-alb-tg-80.arn
  }
  condition {
    host_header {
      values = [
        "/slack/events"
      ]
    }
  }
}
