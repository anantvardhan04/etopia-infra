resource "aws_security_group" "etopia_bastion_sg" {
  vpc_id = aws_vpc.etopia_vpc.id
  name = format("etopia-%s-bastion-sg",var.environment)
  tags = {
    Name = format("etopia-%s-bastion-sg",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_security_group_rule" "etopia_bastion_sgr_1"{
  type              = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.etopia_bastion_sg.id
}
 
resource "aws_security_group_rule" "etopia_bastion_sgr_2"{
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.etopia_bastion_sg.id
}

resource "aws_instance" "etopia-bastion" {
  ami           = "ami-0dfcb1ef8550277af" 
  instance_type = "t2.micro"            
  key_name      = "etopia-dev-key"         
  vpc_security_group_ids = [aws_security_group.etopia_bastion_sg.id]
  subnet_id     = aws_subnet.etopia_public_subnet_1.id

  tags = {
    Name = format("etopia-%s-bastion-instance",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_eip" "etopia-bastion-eip" {
  instance = aws_instance.etopia-bastion.id
  vpc      = true

  tags = {
    Name = format("etopia-%s-bastion-eip",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}




