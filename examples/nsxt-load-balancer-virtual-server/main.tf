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

data "nsxt_policy_lb_app_profile" "nsxt_policy_lb_app_profile" {
  display_name = "default-http-lb-app-profile"
}

module "lb_virtual_server" {
  source                     = "../../modules/nsxt-load-balancer-virtual-server"
  application_profile_path   = data.nsxt_policy_lb_app_profile.nsxt_policy_lb_app_profile.path
  client_ssl                 = var.nsxt_load_balancer_virtual_server_config.client_ssl
  display_name               = var.nsxt_load_balancer_virtual_server_config.display_name
  ip_address                 = var.nsxt_load_balancer_virtual_server_config.ip_address
  ports                      = var.nsxt_load_balancer_virtual_server_config.ports
  default_pool_member_ports  = var.nsxt_load_balancer_virtual_server_config.default_pool_member_ports
  rules                      = var.nsxt_load_balancer_virtual_server_config.rules
  server_ssl                 = var.nsxt_load_balancer_virtual_server_config.server_ssl
  tags                       = var.nsxt_load_balancer_virtual_server_config.tags
  max_concurrent_connections = var.nsxt_load_balancer_virtual_server_config.max_concurrent_connections
  max_new_connection_rate    = var.nsxt_load_balancer_virtual_server_config.max_new_connection_rate
}
