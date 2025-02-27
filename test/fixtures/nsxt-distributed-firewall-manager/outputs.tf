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


output "nsxt_firewall_section" {
  description = "The NSX resource for the created policy."
  value       = module.nsxt-distributed-firewall.nsxt_firewall_section
}

output "nsxt_firewall_section_id" {
  description = "The NSX resource for the created policy."
  value       = module.nsxt-distributed-firewall.nsxt_firewall_section.id
}

output "nsxt_firewall_service" {
  description = "The NSX resource for the created policy."
  value       = module.nsxt-distributed-firewall.nsxt_firewall_service
}

output "nsxt_firewall_service_ids" {
  description = "The NSX resource ID for the created policy."
  value = {
    for k, svc in module.nsxt-distributed-firewall.nsxt_firewall_service : k => svc.id
  }
}

output "nsxt_firewall_ipsets" {
  description = "The NSX resource for created Ip Sets."
  value       = module.nsxt-distributed-firewall.nsxt_firewall_ipsets
}

output "nsxt_firewall_ipsets_ids" {
  description = "The NSX resource ID for created Ip Sets."
  value = {
    for k, ipset in module.nsxt-distributed-firewall.nsxt_firewall_ipsets : k => ipset.id
  }

}
