# Google Cloud VMware Engine IaC Foundations

This repository contains Terraform code to deploy a sample Terraform foundation for Google Cloud VMware Engine. In this repository you can find Terraform modules, deployment examples as well as a set of deployment stages to set up you foundational infrastructure.

## Required Disclaimer

This is not an officially supported Google product. This code is intended to help users setting up their foundational Infrastructure-as-code deployment for Google Cloud VMware Engine. This code is not certified by VMware.

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
    ├── 01-privatecloud
    ├── 02a-nsxt
    ├── 02b-vcenter
    ├── 03-vms
    └── 04-load-balancing
```

 * `examples` contains modular example deployments for each individual module that this repository provides.
 * `modules` contains all modules that are used in the deployment stages.
 * `stages` contains sample deployments for different stages of the foundational deployment which should be executed in the order they are listed.

## Deployment Stages

For an end-to-end deployment of the GCVE IaC Foundation deploy all stages in this repository in the given order. Should you only be interested in a particular use case (e.g. NSX-T management) you can deploy this stage in isolation as long the necessary prerequisites exist (e.g. Private Cloud has been deployed).

The stages are separated by the management component they interact with (Google Cloud, NSX-T, vCenter) as well as the Terraform provider that they are using. The stages are also suggested as an ordered sequence of deployment tasks (e.g. deploy vCenter folder hierarchy as a prerequisite for application VM deployments).

### 01-privatecloud
This stage contains the Terraform content to configure the Monitoring integration with Cloud Monitoring.

### 02a-nsxt
This stage contains the Terraform content for a foundational NSX-T setup (segments, firewalls). This stage can be deployed in parallel with stage `02b-vcenter`.

### 02b-vcenter
This stage contains the Terraform content for a foundational vCenter setup (folders, resource pools, roles). This stage can be deployed in parallel with stage `02a-nsxt`.

### 03-vms
This stage contains the Terraform content for deploying VMs into vCenter.

### 04-network-integrations
This stage contains the Terraform content to deploy load balancers for the previously created VMs.


## Modules

The stages and examples in this repository use modules in the `modules` directory. You can reuse the modules individually:

 * [GCVE Monitoring](./modules/gcve-monitoring)
 * [NSX-T Firewalls](./modules/nsxt-firewall)
 * [NSX-T Load Balancer Pools](./modules/nsxt-load-balancer-pool)
 * [NSX-T Load Balancer Service](./modules/nsxt-load-balancer-service)
 * [NSX-T Load Balancer Virtual Server](./modules/nsxt-load-balancer-virtual-server)
 * [NSX-T Segment](./modules/nsxt-segment)
 * [NSX-T Tier1 Gateway](./modules/nsxt-tier1-gateway)
 * [vCenter Folder](./modules/vcenter-folder)
 * [vCenter Role](./modules/vcenter-role)
 * [vCenter Tag Factory](./modules/vcenter-tag-factory)
 * [vCenter VM](./modules/vcenter-vm)

## Examples

The example directory contains sample code to deploy individual modules. For each example there is a directory where the variables are passed as `tfvars` file and as a `yaml` file. The following examples are available in the `examples` directory:

 * [GCVE Monitoring](./examples/gcve-monitoring)
 * [NSX-T Firewalls](./examples/nsxt-firewall)
 * [NSX-T Load Balancer Pools](./examples/nsxt-load-balancer-pool)
 * [NSX-T Load Balancer Service](./examples/nsxt-load-balancer-service)
 * [NSX-T Load Balancer Virtual Server](./examples/nsxt-load-balancer-virtual-server)
 * [NSX-T Segment](./examples/nsxt-segment)
 * [NSX-T Tier1 Gateway](./examples/nsxt-tier1-gateway)
 * [vCenter Folder](./examples/vcenter-folder)
 * [vCenter Role](./examples/vcenter-role)
 * [vCenter Tag Factory](./examples/vcenter-tag-factory)
 * [vCenter VM](./examples/vcenter-vm)
