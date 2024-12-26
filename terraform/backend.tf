terraform {
  backend "s3" {
    bucket = "hari-demo-terraform98765"
    key    = "terraform/state/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    dynamodb_table = "my-dynamodb-table"
  }
}
