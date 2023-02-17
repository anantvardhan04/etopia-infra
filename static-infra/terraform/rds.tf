resource "aws_db_subnet_group" "etopia-rds-subnet-group" {
  name = format("etopia-%s-rds-subnet-group",var.environment)
  subnet_ids = [aws_subnet.etopia_private_subnet_1.id,aws_subnet.etopia_private_subnet_2.id]
  tags = {
    Name = format("etopia-%s-rds-subnet-group",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_rds_cluster_parameter_group" "etopia-rds-cluster-param" {
  name = format("etopia-%s-cluster-parm-group",var.environment)
  family = "aurora-mysql5.7"
  tags = {
    Name = format("etopia-%s-cluster-parm-group",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_db_parameter_group" "etopia-rds-cluster-instance-param" {
  name = format("etopia-%s-instance-parm-group",var.environment)
  family = "aurora-mysql5.7"
  tags = {
    Name = format("etopia-%s-instance-parm-group",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_rds_cluster_instance" "etopia-rds-cluster-instance" {
  count = var.rds_cluster_instance_number
  identifier = format("etopia-%s-cluster-db-%s", var.environment,count.index + 1)
  cluster_identifier = aws_rds_cluster.etopia-rds-cluster.id
  instance_class = var.db_instance_type
  apply_immediately = true
  db_parameter_group_name = aws_db_parameter_group.etopia-rds-cluster-instance-param.id
  auto_minor_version_upgrade = true
  publicly_accessible = false
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.10.2"
  tags = {
    Name = format("etopia-%s-cluster-db",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_rds_cluster" "etopia-rds-cluster" {
  cluster_identifier = format("etopia-%s-cluster",var.environment)
  database_name = var.db_name
  master_username = var.db_username
  master_password = var.db_password
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.10.2"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.etopia-rds-cluster-param.name
  port = 3306
  db_subnet_group_name = aws_db_subnet_group.etopia-rds-subnet-group.name
  vpc_security_group_ids = [
    aws_security_group.etopia-rds-server-sg.id
  ]
  tags = {
    Name = format("etopia-%s-cluster-db",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_security_group" "etopia-rds-client-sg" {
  vpc_id = aws_vpc.etopia_vpc.id
  name = format("etopia-%s-rds-client-sg",var.environment)
  tags = {
    Name = format("etopia-%s-rds-client-sg",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_security_group_rule" "etopia-rds-client-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.etopia-rds-client-sg.id
}

resource "aws_security_group" "etopia-rds-server-sg" {
  vpc_id = aws_vpc.etopia_vpc.id
  name = format("etopia-%s-rds-server-sg",var.environment)
  tags = {
    Name = format("etopia-%s-rds-server-sg",var.environment)
    Owner = var.tags["owner"]
    CostCenter = var.tags["cost_center"]
    Environment = var.tags["environment"]
    Project = var.tags["project"]
  }
}

resource "aws_security_group_rule" "etopia-rds-server-client-in" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.etopia-rds-server-sg.id
  source_security_group_id = aws_security_group.etopia-rds-client-sg.id
  description = "Accept from client security group"
}

resource "aws_security_group_rule" "etopia-rds-server-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.etopia-rds-server-sg.id
}
