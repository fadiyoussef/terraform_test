provider "aws" {
  region = "ca-central-1"
}
resource "aws_instance" "example" {
  ami		= "ami-0b3f293126f3e2677"
  instance_type	= "t3.micro"
  tags = {
    Name = "terraform-example"
  } 
}	
