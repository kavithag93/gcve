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


variable "vsphere_role_config" {
  type        = list(any)
  description = "Vsphere Role Config"
  default = [
    {
      name       = "cft-test-folder-add-remove"
      privileges = ["Folder.Create", "Folder.Delete"]
    },
    {
      name       = "cft-test-folder-admin"
      privileges = ["Folder.Create", "Folder.Delete", "Folder.Move", "Folder.Rename"]
    },
  ]
}
