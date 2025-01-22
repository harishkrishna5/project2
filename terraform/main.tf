provider "aws" {
  region = var.region  # Referencing the region variable
}

resource "aws_instance" "example" {
  monitoring = true
  ami           = "ami-053b12d3152c0cc71"           # Referencing the ami variable
  instance_type = var.instance_type # Referencing the instance_type variable
  iam_instance_profile = "test"
root_block_device {
 encrypted     = true
 }
ebs_optimized = true
metadata_options {
      http_endpoint = "enabled"
      http_tokens   = "required"
  }


  tags = {
    Name = var.instance_name
  }
}
