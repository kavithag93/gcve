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
  allow_unverified_ssl = false
}

module "vm" {
  for_each      = { for vm in var.vsphere_vm_config : vm.name => vm }
  source        = "../../modules/vcenter-vm"
  vm_name       = each.value.name
  datacenter    = each.value.datacenter
  cluster       = each.value.cluster
  datastore     = each.value.datastore
  resource_pool = each.value.resource_pool
  folder        = each.value.folder
  guest_os_type = each.value.guest_os_type
  num_cpu       = each.value.num_cpu
  num_memory    = each.value.num_memory
  network       = each.value.network
  cdrom_path    = each.value.cdrom_path
  disks         = each.value.disks
}