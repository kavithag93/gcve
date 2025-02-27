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

module "gcve-monitoring" {
  source                  = "../../../modules/gcve-monitoring"
  gcve_region             = var.gcve_region
  project                 = var.project
  secret_vsphere_server   = var.secret_vsphere_server
  secret_vsphere_user     = var.secret_vsphere_user
  secret_vsphere_password = var.secret_vsphere_password
  vm_mon_name             = var.vm_mon_name
  vm_mon_type             = var.vm_mon_type
  vm_mon_zone             = var.vm_mon_zone
  sa_gcve_monitoring      = var.sa_gcve_monitoring
  subnetwork              = var.subnetwork
  create_dashboards       = var.create_dashboards
}