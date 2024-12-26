provider "aws" {
  region = var.region  # Referencing the region variable
}

resource "aws_instance" "example" {
  ami           = var.ami           # Referencing the ami variable
  instance_type = var.instance_type # Referencing the instance_type variable

  tags = {
    Name = var.instance_name
  }
