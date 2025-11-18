resource "aws_security_group" "rds" {
  name        = "umami-rds-sg"
  description = "RDS SG for Umami app"
  vpc_id      = module.vpc.vpc_id

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
  name       = "umami-subnet-group"
  subnet_ids = module.vpc.private_subnets
  tags = {
    Name = "umami-subnet-group"
  }
}

resource "aws_db_instance" "umami" {
  identifier             = "umami-db"
  db_name                = "umami"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = data.aws_ssm_parameter.rds_username.value
  password               = data.aws_ssm_parameter.rds_password.value
  db_subnet_group_name   = aws_db_subnet_group.umami.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = true
}

output "db_address" {
  value = aws_db_instance.umami.endpoint
}

output "db_port" {
  value = aws_db_instance.umami.port
}