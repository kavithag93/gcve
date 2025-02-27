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

data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_storage_policy" "storage_policy" {
  for_each = { for k, v in var.disks : v.storage_policy => k... }
  name     = each.key
}

data "vsphere_storage_policy" "default_storage_policy" {
  name = var.default_storage_policy_id
}

resource "vsphere_virtual_machine" "vsphere_vm" {
  name                       = var.vm_name
  datastore_id               = data.vsphere_datastore.datastore.id
  resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
  folder                     = var.folder
  guest_id                   = var.guest_os_type
  annotation                 = var.annotation
  num_cpus                   = var.num_cpu
  memory                     = var.num_memory
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  dynamic "cdrom" {
    for_each = try(var.cdrom_path, null) == null ? {} : { 0 = var.cdrom_path }
    content {
      datastore_id = data.vsphere_datastore.datastore.id
      path         = cdrom.value
    }
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      label             = disk.key
      size              = disk.value.size
      thin_provisioned  = disk.value.thin_provisioned
      unit_number       = disk.value.unit_number
      storage_policy_id = lookup(data.vsphere_storage_policy.storage_policy, disk.value.storage_policy, data.vsphere_storage_policy.default_storage_policy).id
    }
  }
}