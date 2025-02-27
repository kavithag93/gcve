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

module "gcve_network_peering" {
  source     = "../../../modules/gcve-network-peering"
  project_id = var.project_id

  gcve_peer_name        = var.gcve_peer_name
  gcve_peer_description = var.gcve_peer_description
  peer_network_type     = var.peer_network_type

  # vmware network
  nw_name       = var.nw_name
  nw_location   = var.nw_location
  nw_project_id = var.nw_project_id

  # peer network configs
  peer_nw_name       = var.peer_nw_name
  peer_nw_location   = var.peer_nw_location
  peer_nw_project_id = var.peer_nw_project_id

  peer_export_custom_routes                = var.peer_export_custom_routes
  peer_import_custom_routes                = var.peer_import_custom_routes
  peer_export_custom_routes_with_public_ip = var.peer_export_custom_routes_with_public_ip
  peer_import_custom_routes_with_public_ip = var.peer_import_custom_routes_with_public_ip
}


data "google_vmwareengine_network" "gcve_network" {
  count    = var.dns_peering ? 1 : 0
  project  = var.nw_project_id
  name     = var.nw_name
  location = var.nw_location
}

resource "google_dns_managed_zone" "peering-zone" {
  count      = var.dns_peering ? 1 : 0
  project    = var.project_id
  name       = var.dns_zone_name
  dns_name   = var.dns_name
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = element([for x in data.google_vmwareengine_network.gcve_network[0].vpc_networks : x.network if x.type == "INTRANET"], 0)
    }
  }

  peering_config {
    target_network {
      network_url = "projects/${var.peer_nw_project_id}/global/networks/${var.peer_nw_name}"
    }
  }
}
