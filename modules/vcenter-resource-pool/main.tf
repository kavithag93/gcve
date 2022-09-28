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
  parent_type = split("/", var.parent_path)[0]
  parent_name = split("/", var.parent_path)[1]
  roles = toset(flatten([
    for k, v in var.role_assignments : [
      v.role
    ]
  ]))
  parent_resource_pool_id  = local.parent_type == "Host" ? data.vsphere_host.vsphere_host[0].resource_pool_id : (local.parent_type == "Cluster" ? data.vsphere_compute_cluster.vsphere_compute_cluster[0].resource_pool_id : data.vsphere_resource_pool.vsphere_resource_pool[0].id)
}

data "vsphere_datacenter" "vsphere_datacenter" {
  name = var.datacenter
}

data "vsphere_host" "vsphere_host" {
  count         = local.parent_type == "Host" ? 1 : 0
  name          = local.parent_name
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter.id
}

data "vsphere_compute_cluster" "vsphere_compute_cluster" {
  count         = local.parent_type == "Cluster" ? 1 : 0
  name          = local.parent_name
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter.id
}

data "vsphere_resource_pool" "vsphere_resource_pool" {
  count         = local.parent_type == "ResourcePool" ? 1 : 0
  name          = local.parent_name
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter.id
}

data "vsphere_role" "vsphere_role" {
  for_each = local.roles
  label    = each.value
}

resource "vsphere_resource_pool" "resource_pool" {
  name = var.name
  parent_resource_pool_id  = local.parent_resource_pool_id
  cpu_share_level          = var.cpu_share_level
  cpu_shares               = var.cpu_shares
  cpu_reservation          = var.cpu_reservation
  cpu_expandable           = var.cpu_expandable
  cpu_limit                = var.cpu_limit
  memory_share_level       = var.memory_share_level
  memory_shares            = var.memory_shares
  memory_reservation       = var.memory_reservation
  memory_expandable        = var.memory_expandable
  memory_limit             = var.memory_limit
  scale_descendants_shares = var.scale_descendants_shares
  tags                     = var.resource_pool_tags
}

resource "vsphere_entity_permissions" "entity_permissions" {
  for_each    = var.role_assignments
  entity_id   = vsphere_resource_pool.resource_pool.id
  entity_type = "ResourcePool"
  permissions {
    user_or_group = each.value.user_or_group
    is_group      = each.value.is_group
    propagate     = each.value.propagate
    role_id       = data.vsphere_role.vsphere_role[each.value.role].id
  }
}
