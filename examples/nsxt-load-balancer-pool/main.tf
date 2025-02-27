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

module "lb_pool" {
  source                   = "../../modules/nsxt-load-balancer-pool"
  display_name             = var.nsxt_load_balancer_pool_config.display_name
  algorithm                = var.nsxt_load_balancer_pool_config.algorithm
  min_active_members       = var.nsxt_load_balancer_pool_config.min_active_members
  members                  = try(var.nsxt_load_balancer_pool_config.members, {})
  tags                     = try(var.nsxt_load_balancer_pool_config.tags, {})
  snat                     = try(var.nsxt_load_balancer_pool_config.snat, null)
  tcp_multiplexing_enabled = var.nsxt_load_balancer_pool_config.tcp_multiplexing_enabled
}