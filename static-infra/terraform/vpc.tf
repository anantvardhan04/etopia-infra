resource "aws_vpc" "etopia_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = format("etopia-%s-vpc",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "etopia_igw" {
  name = format("etopia-%s-igw",var.environment)
  vpc_id = aws_vpc.etopia_vpc.id

  tags = {
    Name = format("etopia-%s-igw",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
}

resource "aws_subnet" "etopia_public_subnet_1" {
  name   = format("etopia-%s-pub-subnet-1",var.environment)
  vpc_id     = aws_vpc.etopia_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = format("etopia-%s-pub-subnet-1",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
}

resource "aws_subnet" "etopia_public_subnet_2" {
  name = format("etopia-%s-pub-subnet-2",var.environment)
  vpc_id     = aws_vpc.etopia_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"

  tags = {
    Name = format("etopia-%s-pub-subnet-2",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
}

resource "aws_eip" "etopia_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "etopia_nat_gw" {
  name = format("etopia-%s-nat-gw",var.environment)
  allocation_id = aws_eip.etopia_nat_eip.id
  subnet_id     = aws_subnet.etopia_public_subnet_2.id

  tags = {
    Name = format("etopia-%s-nat-gw",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
}

resource "aws_subnet" "etopia_private_subnet_1" {
  name = format("etopia-%s-pvt-subnet-1",var.environment)
  vpc_id     = aws_vpc.etopia_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = format("etopia-%s-pvt-subnet-1",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_subnet" "etopia_private_subnet_2" {
  name = format("etopia-%s-pvt-subnet-2",var.environment)
  vpc_id     = aws_vpc.etopia_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = format("etopia-%s-pvt-subnet-2",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.environment
  }
  depends_on = [aws_nat_gateway.nat_gw]
}