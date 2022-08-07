# Google Cloud VMware Engine IaC Foundations

This repository contains end-to-end examples and a suite of Terraform modules
to deploy a sample Terraform foundation for Google Cloud VMware Engine.

## Structure

The repository has the following structure
```
├── examples
│   ├── nsxt-firewall
│   ├── nsxt-load-balancer-pool
│   ├── nsxt-load-balancer-service
│   ├── ...
├── modules
│   ├── nsxt-firewall
│   ├── nsxt-load-balancer-pool
│   ├── nsxt-load-balancer-service
│   ├── ...
└── stages
    ├── 00-bootstrap
    ├── 01-privatecloud
    ├── 02a-nsxt
    ├── 02b-vcenter
    ├── 03-vms
    └── 04-network-integrations
```

 * `examples` contains modular example deployments for each individual module that this repository provides.
 * `modules` contains all modules that are used in the deployment stages.
 * `stages` contains sample deployments for different stages of the foundational deployment which should be executed in the order they are listed.

## Deployment Stages

For an end-to-end deployment of the GCVE IaC Foundation deploy all stages in this repository in the given order. Should you only be interested in a particular use case (e.g. NSX-T management) you can deploy this stage in isolation as long the necessary prerequisites exist (e.g. Private Cloud has been deployed).

### 00-bootstrap
This stage contains setup scripts and instructions which are a prerequisite to later stages (IAM, network)

### 01-privatecloud
This stage contains the Terraform content to deploy Private Clouds and configure the Monitoring integration with Cloud Monitoring.

### 02a-nsxt
This stage contains the Terraform content for a foundational NSX-T setup (segments, firewalls). This stage can be deployed in parallel with stage `02b-vcenter`.

### 02b-vcenter
This stage contains the Terraform content for a foundational vCenter setup (folders, resource pools, roles). This stage can be deployed in parallel with stage `02a-nsxt`.

### 03-vms
This stage contains the Terraform content for deploying VMs into vCenter.

### 04-network-integrations
This stage contains the Terraform content to deploy load balancers for the previously created VMs.