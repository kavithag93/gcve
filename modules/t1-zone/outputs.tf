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

output "nsxt_tier1_gateway" {
  description = "The NSX resource object of the created Tier1 gateway."
  value       = nsxt_policy_tier1_gateway.t1_router
}

output "segments" {
  value = {
    for k, segments in nsxt_policy_fixed_segment.segments : k => nsxt_policy_fixed_segment.segments
  }
}

output "gw_firewall_rules" {
  value = module.gwf_policies

}