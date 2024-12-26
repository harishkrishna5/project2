#!/bin/bash

# Ensure that Terraform is initialized
terraform init

# Run Terraform destroy to remove all infrastructure
terraform destroy -auto-approve
