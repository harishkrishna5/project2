# Specify the provider and region for AWS
provider "aws" {
  region = "ap-south-1"  # Replace with your desired region
}

# Create a security group to allow SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
 

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Create an EC2 key pair for SSH access
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "my-key-pair"  # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with your public key file path
}

# Create an EC2 instance
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-053b12d3152c0cc71"  # Replace with the desired AMI ID (Amazon Linux 2 in this example)
  instance_type = "t2.micro"  # You can choose a different instance type depending on your needs

  # Associate the key pair
  key_name = aws_key_pair.ec2_key_pair.key_name

  # Associate the security group
  security_groups = [aws_security_group.allow_ssh.name]

  # Tag the instance
  tags = {
    Name = "MyEC2Instance"
  }

  # Optionally, enable monitoring
  monitoring = true
}

# Outputs
output "instance_public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
}

output "instance_id" {
  value = aws_instance.my_ec2_instance.id
}
