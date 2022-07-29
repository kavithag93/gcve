/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  config_file = "config.yaml"
  config_data = yamldecode(file(local.config_file))
  nsxt        = try(local.config_data["nsxt"], {})
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    nsxt = {
      source  = "vmware/nsxt"
      version = ">= 3.2.7"
    }
  }
}

provider "nsxt" {
  host                 = var.nsxt_url
  username             = var.nsxt_user
  password             = var.nsxt_password
  allow_unverified_ssl = true
}

data "nsxt_policy_edge_cluster" "edge-cluster" {
  display_name = "edge-cluster"
}

data "nsxt_policy_tier0_gateway" "tier0-gateway" {
  display_name = "Provider-LR"
}

module "tier1-gateway" {
  source             = "../../nsxt-tier1-gateway/"
  edge_cluster_path  = data.nsxt_policy_edge_cluster.edge-cluster.path
  tier0_gateway_path = data.nsxt_policy_tier0_gateway.tier0-gateway.path
}

module "nsxt-firewall" {
  source             = "../"
  display_name       = local.nsxt.policy_name
  tier1_gateway_path = module.tier1-gateway.path
  custom_l4_services = local.nsxt.custom_l4_services
  rules              = local.nsxt.rules
}
