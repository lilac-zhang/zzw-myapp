variable "my_ip" {
  default = "113.148.112.187/32"  
}


# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = "vpc-06992be4b24818bd1"

  
  ingress {
    description = "My laptop"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  
  ingress {
    description     = "From ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Subnet Group
resource "aws_db_subnet_group" "main" {
  name = "my-db-subnet"

  subnet_ids = [
    "subnet-0c93a6762611fc349",
    "subnet-0e744431e5f5d940b"
  ]
}

# RDS Instance
resource "aws_db_instance" "postgres" {
  identifier = "my-todo-db"

  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = "todo_db"
  username = "postgres"
  password = var.db_password

  publicly_accessible = true   

  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}


# Output
output "db_endpoint" {
  value = aws_db_instance.postgres.address
}