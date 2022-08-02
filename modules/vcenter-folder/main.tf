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
  roles = toset(flatten( [
    for k, v in var.role_assignments: [
      v.role
    ]
  ]))
}

data "vsphere_datacenter" "vsphere_datacenter" {
  name = var.datacenter
}

data "vsphere_role" "vsphere_role" {
  for_each = local.roles
  label    = each.value
}

data "vsphere_custom_attribute" "attribute" {
  count = length(var.custom_attributes)
  name  = var.custom_attributes[count.index].name
}

data "vsphere_tag_category" "category" {
  count = length(var.tags)
  name  = var.tags[count.index].category_name
}

resource "vsphere_tag" "tag" {
  count       = length(var.tags)
  name        = var.tags[count.index].name
  category_id = data.vsphere_tag_category.category[count.index].id
  description = var.tags[count.index].description
}

resource "vsphere_folder" "vsphere_folder" {
  path              = var.folder_path
  type              = var.folder_type
  datacenter_id     = data.vsphere_datacenter.vsphere_datacenter.id
  custom_attributes =  tomap({ for idx, ca in var.custom_attributes : data.vsphere_custom_attribute.attribute[idx].id => ca.value })
  tags              = length(var.tags) == 0 ? [] : toset([for k, v in var.tags : vsphere_tag.tag[k].id])
}

resource "vsphere_entity_permissions" "vsphere_entity_permissions" {
  count       = length(var.role_assignments) == 0 ? 0 : 1
  entity_id   = vsphere_folder.vsphere_folder.id
  entity_type = var.vsphere_folder_object_type

  dynamic "permissions" {
    for_each = { for idx, permission in var.role_assignments : idx => permission }
    content {
      user_or_group = permissions.value["user_or_group"]
      is_group      = permissions.value["is_group"]
      propagate     = permissions.value["propagate"]
      role_id       = data.vsphere_role.vsphere_role[permissions.value["role"]].id
    }
  }
  depends_on = [vsphere_folder.vsphere_folder]
}
