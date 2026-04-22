provider "aws" {
  region = "ap-northeast-1"
}

# セキュリティーグループ（22, 80，5000）
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "allow ssh and http"
  vpc_id      = "vpc-06992be4b24818bd1"   

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "Flask"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2
resource "aws_instance" "web" {
  ami           = "ami-088b486f20fab3f0e" 
  instance_type = "t3.micro"

  subnet_id = "subnet-0c93a6762611fc349"   

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  key_name = "222"

  associate_public_ip_address = true


  user_data = <<-EOF
              #!/bin/bash

              yum update -y
              yum install -y docker cronie

              systemctl enable docker
              systemctl start docker

              systemctl enable crond
              systemctl start crond
             

              usermod -aG docker ec2-user
              sleep 10

              
              IMAGE="lilaczhang/my_app:latest"
              CONTAINER="myapp"
              
              docker pull $IMAGE
              docker stop $CONTAINER || true
              docker rm $CONTAINER || true
              docker run -d -p 5000:5000 \
               -e DB_HOST=${aws_db_instance.postgres.address} \
               -e DB_NAME=todo_db \
               -e DB_USER=postgres \
               -e DB_PASSWORD=${var.db_password} \
               --name $CONTAINER $IMAGE
              cat << 'EOT' > /home/ec2-user/update.sh
              #!/bin/bash

              IMAGE="lilaczhang/my_app:latest"
              CONTAINER="myapp"

              echo "Checking for updates..."

              docker pull $IMAGE

              CURRENT=$(docker inspect --format='{{.Image}}' $CONTAINER 2>/dev/null || echo "")
              LATEST=$(docker inspect --format='{{.Id}}' $IMAGE)
              
              echo "CURRENT: $CURRENT"
              echo "LATEST:  $LATEST"

              if [ "$CURRENT" != "$LATEST" ]; then
               docker stop $CONTAINER || true
               docker rm $CONTAINER || true
               docker run -d -p 5000:5000 \
                 -e DB_HOST=${aws_db_instance.postgres.address} \
                 -e DB_NAME=todo_db \
                 -e DB_USER=postgres \
                 -e DB_PASSWORD=${var.db_password} \
                 --name $CONTAINER $IMAGE
              else
               echo "No update"
              fi
              EOT
             
              chmod +x /home/ec2-user/update.sh
              chown ec2-user:ec2-user /home/ec2-user/update.sh

              echo "* * * * * /home/ec2-user/update.sh >> /home/ec2-user/update.log 2>&1" | crontab -u ec2-user -

              EOF

  tags = {
    Name = "zzw-ec2"
  }
}