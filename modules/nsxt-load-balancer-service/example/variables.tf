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

variable "nsxt_url" {
  type        = string
  description = "The URL of the NSX-T endpoint"
}

variable "nsxt_user" {
  type        = string
  description = "The username used to connect to the NSX-T endpoint. Must be an admin user"
  sensitive   = true
}

variable "nsxt_password" {
  type        = string
  description = "The password for the NSX-T user"
  sensitive   = true
}

variable "existing_tier1_gateway_name" {
  type        = string
  description = "Name of the tier1 gateway where the Load balancer service will be attached"
  default     = null
}
