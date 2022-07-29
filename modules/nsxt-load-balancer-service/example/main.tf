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
  allow_unverified_ssl = false
}

data "nsxt_policy_tier0_gateway" "tier0-gateway" {
  display_name = "Provider-LR"
}

data "nsxt_policy_edge_cluster" "edge-cluster" {
  display_name = "edge-cluster"
}

module "tier1-gateway" {
  source             = "../../nsxt-tier1-gateway/"
  edge_cluster_path  = data.nsxt_policy_edge_cluster.edge-cluster.path
  tier0_gateway_path = data.nsxt_policy_tier0_gateway.tier0-gateway.path
}

module "lb-service" {
  source            = "../"
  connectivity_path = module.tier1-gateway.path
  display_name      = local.nsxt.display_name
  enabled           = local.nsxt.enabled
  tags              = local.nsxt.tags
}
