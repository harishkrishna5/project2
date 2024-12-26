variable "region" {
  description = "The AWS region where the EC2 instance will be created"
  type        = string
  default     = "us-west-2"
}

variable "ami" {
  description = "The AMI ID to launch the instance"
  type        = string
  default     = "ami-022ce6f32988af5fa"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
variable "instance_name" {
  description = "The name tag for the EC2 instance"
  type        = string
  default     = "My EC2 Instance"
}
