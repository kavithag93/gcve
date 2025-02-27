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

# variable "nsxt_url" {
#   description = "The URL of the NSX-T endpoint"
#   type        = string
# }

# variable "nsxt_user" {
#   description = "The username used to connect to the NSX-T endpoint. Must be an admin user"
#   type        = string
#   sensitive   = true
# }

# variable "nsxt_password" {
#   description = "The password for the NSX-T user"
#   type        = string
#   sensitive   = true
# }

variable "nsxt_load_balancer_service_config" {
  description = "NSXT Load Balancer Service Config"
  type = object({
    display_name = string,
    enabled      = bool,
    tags         = map(string),
  })
}