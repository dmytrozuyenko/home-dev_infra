resource "aws_db_instance" "postgres" {
  identifier             = "postgres"
  endpoint               = "postgres:5432"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.1"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_vpc.home.id
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
}
