# Private Cloud

## Private Cloud Deployment

Use this deployment stage to deploy a new private cloud.

## Prerequisites

 * You have a Google Cloud project with the VMware Engine API enabled

## Instructions

To deploy this stage from a local UNIX shell, follow the steps:
 * Rename (or copy) the file `terraform.tfvars.example` to `terraform.tfvars` and fill in suitable variables for your environment.
 * Initialize Terraform: `terraform init`
 * Validate the resources created by Terraform: `terraform plan`
 * Apply Terraform configurations: `terraform apply`
