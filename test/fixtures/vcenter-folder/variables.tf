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

variable "vsphere_folder_config" {
  description = "All Vsphere Folder Configs"
  type        = any
  default = {
    "datacenter" : "Datacenter",
    "path" : "folder-cft-test",
    "type" : "vm",
    "custom_attributes" : {
    },
    "tags" : {
    },
    "role_assignments" : {
      "permission1" : {
        "user_or_group" : "vsphere.local\\\\DCClients",
        "is_group" : true,
        "propagate" : true,
        "role" : "Monitoring-Role"
      }
    }
  }
}