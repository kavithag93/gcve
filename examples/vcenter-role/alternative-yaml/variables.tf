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
  sensitive   = true
}

variable "vsphere_user" {
  type        = string
  description = "The username used to connect to the vCenter server. Must be an admin user"
  sensitive   = true
}

variable "vsphere_password" {
  type        = string
  description = "The password for the vCenter admin user"
  sensitive   = true
}

variable "config_location" {
  description = "Yaml file location path"
  type        = string
  default     = "terraform.yaml"
}


