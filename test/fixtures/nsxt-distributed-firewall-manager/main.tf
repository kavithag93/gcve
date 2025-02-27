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

module "nsxt-distributed-firewall" {
  source = "../../../examples/nsxt-distributed-firewall-manager"

  nsxt_dfw_section_description   = var.nsxt_dfw_section_description
  nsxt_dfw_section_display_name  = var.nsxt_dfw_section_display_name
  nsxt_dfw_insert_before_section = var.nsxt_dfw_insert_before_section
  nsxt_dfw_section_type          = var.nsxt_dfw_section_type
  nsxt_dfw_section_applied_to    = var.nsxt_dfw_section_applied_to

  nsxt_dfw_rules              = var.nsxt_dfw_rules
  nsxt_dfw_ip_sets            = var.nsxt_dfw_ip_sets
  nsxt_dfw_custom_l4_services = var.nsxt_dfw_custom_l4_services
  nsxt_dfw_section_tags       = var.nsxt_dfw_section_tags
}