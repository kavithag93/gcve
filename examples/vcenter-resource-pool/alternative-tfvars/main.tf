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

provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}

module "resource_pool" {
  for_each = { for resource_pool in var.vsphere_resource_pool_config : resource_pool.name => resource_pool }
  source   = "../../../modules/vcenter-resource-pool"

  name             = each.key
  datacenter       = each.value.datacenter
  parent_path      = each.value.location
  role_assignments = each.value.role_assignments
}
