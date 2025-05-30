# Define the AWS provider and region.
provider "aws" {
  region = "us-east-1" # Hardcoded for clarity, can be passed via variable if needed
}

# Define a security group to allow SSH access.
resource "aws_security_group" "ssh_sg" {
  name        = "jenkins-ssh-sg"
  description = "Allow SSH inbound traffic for Jenkins pipeline"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // WARNING: Restrict this in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-ssh-sg"
  }
}

# Data source to find the most recent Ubuntu Server 22.04 LTS AMI.
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical's owner ID
}

# Data source to get the default VPC.
data "aws_vpc" "default" {
  default = true
}

# Define the EC2 instance.
resource "aws_instance" "jenkins_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "jenkins"  # IMPORTANT: This refers to the name of the EC2 Key Pair
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "JenkinsManagedEC2"
  }
}

# Output the public IP address of the EC2 instance.
output "public_ip" {
  value       = aws_instance.jenkins_ec2.public_ip
  description = "The public IP address of the EC2 instance."
}
