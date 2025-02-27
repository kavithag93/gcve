/**
 * Copyright 2023 Google LLC
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

module "gcve-private-cloud" {
  source                            = "../../../modules/gcve-private-cloud"
  project                           = var.project
  gcve_zone                         = var.gcve_zone
  vmware_engine_network_name        = var.vmware_engine_network_name
  vmware_engine_network_type        = var.vmware_engine_network_type
  vmware_engine_network_description = var.vmware_engine_network_description
  vmware_engine_network_location    = var.vmware_engine_network_location
  create_vmware_engine_network      = var.create_vmware_engine_network
  pc_name                           = var.pc_name
  pc_cidr_range                     = var.pc_cidr_range
  pc_description                    = var.pc_description
  cluster_id                        = var.cluster_id
  cluster_node_type                 = var.cluster_node_type
  cluster_node_count                = var.cluster_node_count
}
