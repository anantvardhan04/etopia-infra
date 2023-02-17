resource "aws_vpc" "etopia_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = format("etopia-%s-vpc",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_internet_gateway" "etopia_igw" {
  vpc_id = aws_vpc.etopia_vpc.id

  tags = {
    Name = format("etopia-%s-igw",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_subnet" "etopia_public_subnet_1" {
  vpc_id     = aws_vpc.etopia_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = format("etopia-%s-pub-subnet-1",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_subnet" "etopia_public_subnet_2" {
  vpc_id     = aws_vpc.etopia_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"

  tags = {
    Name = format("etopia-%s-pub-subnet-2",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_eip" "etopia_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "etopia_nat_gw" {
  allocation_id = aws_eip.etopia_nat_eip.id
  subnet_id     = aws_subnet.etopia_public_subnet_2.id

  tags = {
    Name = format("etopia-%s-nat-gw",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_subnet" "etopia_private_subnet_1" {
  vpc_id     = aws_vpc.etopia_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = format("etopia-%s-pvt-subnet-1",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
  depends_on = [aws_nat_gateway.etopia_nat_gw]
}

resource "aws_subnet" "etopia_private_subnet_2" {
  vpc_id     = aws_vpc.etopia_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = format("etopia-%s-pvt-subnet-2",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
  depends_on = [aws_nat_gateway.etopia_nat_gw]
}

resource "aws_route_table" "etopia-pub-route-table" {
  vpc_id = aws_vpc.etopia_vpc.id
  tags = {
    Name = format("etopia-%s-pub-route-table",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_route" "etopia-pub-route-table-rule" {
  route_table_id = aws_route_table.etopia-pub-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.etopia_igw.id
}

resource "aws_route_table_association" "etopia-pub-route-table-assoc-sub-1" {
  subnet_id = aws_subnet.etopia_public_subnet_1.id
  route_table_id = aws_route_table.etopia-pub-route-table.id
}

resource "aws_route_table_association" "etopia-pub-route-table-assoc-sub-2" {
  subnet_id = aws_subnet.etopia_public_subnet_2.id
  route_table_id = aws_route_table.etopia-pub-route-table.id
}

resource "aws_route_table" "etopia-pvt-route-table" {
  vpc_id = aws_vpc.etopia_vpc.id
  tags = {
    Name = format("etopia-%s-pvt-route-table",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}
resource "aws_route" "etopia-pvt-route-table-rule" {
  route_table_id = aws_route_table.etopia-pvt-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.etopia_nat_gw.id
}

resource "aws_route_table_association" "etopia-pvt-route-table-assoc-sub-1" {
  subnet_id = aws_subnet.etopia_private_subnet_1.id
  route_table_id = aws_route_table.etopia-pvt-route-table.id
}

resource "aws_route_table_association" "etopia-pvt-route-table-assoc-sub-2" {
  subnet_id = aws_subnet.etopia_private_subnet_2.id
  route_table_id = aws_route_table.etopia-pvt-route-table.id
}