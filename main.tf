provider "aws" {
  region = "ca-central-1"
}
resource "aws_security_group" "instance" {
  name ="terraform-example.instance"
  ingress{
    from_port = 8080
    to_port =8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   # Port 80 (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Port 443 (HTTPS)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 1. Define the Security Group with SSH Ingress
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow inbound SSH traffic"

  # Inbound Rules
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Opens SSH to the entire internet
  }

  # Outbound Rules (Terraform removes default AWS "allow-all" egress unless specified)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami		= "ami-0b3f293126f3e2677"
  instance_type	= "t3.micro"
  vpc_security_group_ids =[aws_security_group.instance.id, aws_security_group.allow_ssh.id]
  user_data = <<-EOF
  #!/bin/bash
  cd /var/
  echo "Hello, World" > index.html
  # Starts a native, lightweight web server on port 8080
  nohup python3 -m http.server 8080 &
  EOF
  tags = {
    Name = "terraform-example"
  } 
}
