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
}
resource "aws_instance" "example" {
  ami		= "ami-0b3f293126f3e2677"
  instance_type	= "t3.micro"
  vpc_security_group_ids =[aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              # Starts a native, lightweight web server on port 8080
              nohup python3 -m http.server 8080 &
              EOF
  tags = {
    Name = "terraform-example"
  } 
}
