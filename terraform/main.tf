provider "aws" {
  region = var.region  # Referencing the region variable
}

resource "aws_instance" "example" {
  ami           = "ami-053b12d3152c0cc71"           # Referencing the ami variable
  instance_type = var.instance_type # Referencing the instance_type variable


  tags = {
    Name = var.instance_name
  }
}
