resource "aws_security_group" "etopia-app-sg" {
  vpc_id = aws_vpc.etopia_vpc.id
  name = format("etopia-%s-app-sg", var.environment)
  tags = {
    Name = format("etopia-%s-app-sg", var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_security_group_rule" "etopia-sg-80-rule" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.etopia-ext-alb-sg.id
  security_group_id = aws_security_group.etopia-app-sg.id
  description = "Allow traffic on port 80 from ALB security group"
}

resource "aws_security_group_rule" "etopia-sg-bastion-rule" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = aws_security_group.etopia_bastion_sg.id
  security_group_id = aws_security_group.etopia-app-sg.id
  description = "Allow traffic on port 22 from Bastion security group"
}

resource "aws_security_group_rule" "etopia-app-sg-ext-eg" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.etopia-ext-alb-sg.id
}