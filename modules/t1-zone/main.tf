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



resource "nsxt_policy_tier1_gateway" "t1_router" {
  description               = var.t1_description
  display_name              = var.t1_name
  edge_cluster_path         = var.edge_cluster_path
  failover_mode             = var.t1_failover_mode
  default_rule_logging      = var.t1_default_rule_logging
  enable_firewall           = var.t1_enable_firewall
  enable_standby_relocation = var.t1_enable_standby_relocation
  tier0_path                = var.t0_path
  route_advertisement_types = var.t1_route_advertisement_types
  pool_allocation           = var.t1_pool_allocation

}

resource "nsxt_policy_fixed_segment" "segments" {
  for_each            = var.segments
  display_name        = each.value.display_name
  description         = each.value.description
  connectivity_path   = nsxt_policy_tier1_gateway.t1_router.path
  transport_zone_path = var.overlay_tz_path
  subnet {
    cidr = each.value.subnet.cidr
  }

}

module "gwf_policies" {

  source   = "../nsxt-gateway-firewall/"
  for_each = { for k, v in var.gwf_policies : v.display_name => v }

  display_name    = each.value.display_name
  rules           = each.value.rules
  sequence_number = each.value.sequence_number
  scope_path      = nsxt_policy_tier1_gateway.t1_router.path
}