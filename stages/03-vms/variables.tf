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

variable "vsphere_server" {
  type        = string
  description = "The FQDN of the vSphere vCenter server"
}

variable "vsphere_user" {
  type        = string
  description = "The username used to connect to the vCenter server. Must be an admin user"
}

variable "vsphere_password" {
  type        = string
  description = "The password for the vCenter admin user"
  sensitive   = true
}

variable "vsphere_vm_config" {
  description = "All Vsphere VM Configs"
  type = map(object({
    datacenter    = string,
    cluster       = string,
    datastore     = string,
    resource_pool = string,
    folder        = string,
    guest_os_type = string,
    cdrom_path    = optional(string),
    num_cpu       = number,
    num_memory    = number,
    network       = string,
    disks         = any
  }))
}
