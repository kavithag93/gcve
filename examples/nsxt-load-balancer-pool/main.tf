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

module "lb-pool" {
  source                   = "../../modules/nsxt-load-balancer-pool"
  display_name             = local.nsxt.display_name
  members                  = try(local.nsxt.members, {})
  tags                     = try(local.nsxt.tags, {})
  snat                     = try(local.nsxt.snat, null)
  tcp_multiplexing_enabled = local.nsxt.tcp_multiplexing_enabled
}

output "lb-pool" {
  value = module.lb-pool
}