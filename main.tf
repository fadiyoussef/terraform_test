provider "aws" {
  region = "ca-central-1"
}
variable "server_ports"{
  description = "open ports in use for browsing"
  type = list
  default = [80, 8080, 443]
}
resource "aws_security_group" "instance" {
  name ="terraform-example.instance"
  dynamic "ingress" {
    for_each = var.server_ports 
    content {
    from_port = ingress.value
    to_port = ingress.value
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
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

resource "aws_launch_template" "example" {
  name_prefix   = "terraform-example-"
  image_id		= "ami-0b3f293126f3e2677"
  instance_type	= "t3.micro"
  network_interfaces {
  security_groups =[aws_security_group.instance.id, aws_security_group.allow_ssh.id]
  }
    user_data = base64encode(
    templatefile("${path.module}/launch.sh", {
      server_ports = var.server_ports
    })
  )
    lifecycle {
    create_before_destroy = true
  }
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_autoscaling_group" "example" {
  desired_capacity   = 2
  min_size =  2
  max_size = 10
  vpc_zone_identifier = data.aws_subnets.default.ids
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest" # Automatically uses the newest iteration of your template
  }
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}
