resource "aws_security_group" "etopia-packer-sg" {
  vpc_id = aws_vpc.etopia_vpc.id
  name = format("etopia-%s-packer-sg", var.environment)
  description = "Packer Etopia Security Group"
  tags = {
    Name = format("etopia-%s-packer-sg", var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environemnt"]
    Project = var.tags["project"]
  }
}

resource "aws_security_group_rule" "etopia-packer-in" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.etopia-packer-sg.id
  description = "Etopia packer"
}

resource "aws_security_group_rule" "etopia-packer-eg" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.etopia-packer-sg.id
  description = "Etopia packer"
}