resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_db_subnet_group" "umami" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = var.private_subnets
  
  tags = {
    Name = "umami-subnet-group"
  }
}

resource "aws_db_instance" "umami" {
  identifier             = var.db_identifier
  db_name                = var.db_name
  engine                 = "postgres"
  instance_class         = var.instance_type
  allocated_storage      = var.allocated_storage
  username               = var.rds_username
  password               = var.rds_password
  db_subnet_group_name   = aws_db_subnet_group.umami.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = var.publicly_accessible
}

output "db_address" {
  value = aws_db_instance.umami.endpoint
}

output "db_port" {
  value = aws_db_instance.umami.port
}
