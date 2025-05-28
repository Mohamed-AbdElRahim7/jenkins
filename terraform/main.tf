provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0f88e80871fd81e91"
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "jenkins-ec2"
  }
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}


### terraform/variables.tf

variable "key_name" {
  description = "The key name to use for the EC2 instance"
  type        = string
}
