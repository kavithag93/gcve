/*
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

# provider "nsxt" {
#   host                 = var.nsxt_url
#   username             = var.nsxt_user
#   password             = var.nsxt_password
#   allow_unverified_ssl = false
# }

data "nsxt_policy_tier0_gateway" "tier_0_gateway" {
  display_name = "Provider-LR"
}

data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = "edge-cluster"
}

module "tier_1_gateway" {
  source             = "../../modules/nsxt-tier1-gateway"
  edge_cluster_path  = data.nsxt_policy_edge_cluster.edge_cluster.path
  tier0_gateway_path = data.nsxt_policy_tier0_gateway.tier_0_gateway.path
}

module "lb_service" {
  source            = "../../modules/nsxt-load-balancer-service"
  connectivity_path = module.tier_1_gateway.path
  display_name      = var.nsxt_load_balancer_service_config.display_name
  enabled           = var.nsxt_load_balancer_service_config.enabled
  tags              = var.nsxt_load_balancer_service_config.tags
}
