resource "aws_security_group" "rds_sg" {
  name = "rds-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ 测试用
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "my-todo-db"

  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"

  allocated_storage = 10
  storage_type      = "gp2"

  db_name  = "todo_db"
  username = "postgres"
  password = "mypassword123"   # ⚠️ 后面会优化

  publicly_accessible = true

  backup_retention_period = 1
  skip_final_snapshot     = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}