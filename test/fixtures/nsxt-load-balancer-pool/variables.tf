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

variable "nsxt_load_balancer_pool_config" {
  description = "NSXT Load Balancer Pool Config"
  type = object({
    display_name       = string,
    algorithm          = string,
    min_active_members = number,
    members = map(object({
      ip_address                 = string
      admin_state                = optional(string)
      backup_member              = optional(bool)
      max_concurrent_connections = optional(number)
      port                       = optional(string)
      weight                     = optional(number)
    })),
    tags = map(string),
    snat = object({
      type              = string
      ip_pool_addresses = optional(list(string))
    }),
    tcp_multiplexing_enabled = bool
  })

  default = {
    display_name       = "cft_test_lb_pool",
    algorithm          = "IP_HASH",
    min_active_members = 2,
    members = {
      foo1 = {
        ip_address = "10.51.0.69"
      },
      foo2 = {
        ip_address = "10.51.0.96"
      },
    },
    tags = {
      env = "dev"
    },
    snat = {
      type = "AUTOMAP"
    },
    tcp_multiplexing_enabled = true
  }
}