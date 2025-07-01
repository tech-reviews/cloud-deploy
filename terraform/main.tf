provider "aws" {
  region = "us-east-1"
}

# Key pair (make sure this public key exists)
resource "aws_key_pair" "cloud_deploy_key" {
  key_name   = "cloud-deploy-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Security group to allow SSH & app port
resource "aws_security_group" "cloud_deploy_sg" {
  name        = "cloud-deploy-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "cloud_deploy_instance" {
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2 in us-east-1 (update as needed)
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.cloud_deploy_key.key_name
  vpc_security_group_ids      = [aws_security_group.cloud_deploy_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 8080:8080 --name cloud-deploy zechary/cloud-deploy:latest
              EOF

  tags = {
    Name = "cloud-deploy-instance"
  }
}

# Elastic IP
resource "aws_eip" "cloud_deploy_eip" {
  instance = aws_instance.cloud_deploy_instance.id
}

output "public_ip" {
  description = "Public IP of the cloud-deploy EC2 instance"
  value       = aws_eip.cloud_deploy_eip.public_ip
}
