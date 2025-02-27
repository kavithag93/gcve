# Private Cloud

## Network Peering

Use this stage to setup network peering with your GCP VPC network with your GCVE VMWare Engine Network.

This stage also consist of an optional step where DNS peering can be configured for private hosted zone to GCVE Intranet Network, that will allow GCVE VMs to resolve private hosted zones entried.

For VMWare Engine Network DNS bind permission, terraform user should have bind permission that can be allowed using gcloud - `gcloud vmware dns-bind-permission grant --user=umeshkumhar@google.com`

## Prerequisites

 * You have a Google Cloud project with the VMware Engine API enabled


## Instructions

To deploy this stage from a local UNIX shell, follow the steps:
 * Rename (or copy) the file `terraform.tfvars.example` to `terraform.tfvars` and fill in suitable variables for your environment.
 * Initialize Terraform: `terraform init`
 * Validate the resources created by Terraform: `terraform plan`
 * Apply Terraform configurations: `terraform apply`
