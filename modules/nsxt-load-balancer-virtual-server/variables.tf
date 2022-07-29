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

variable "access_log_enabled" {
  description = "Should the access log be enabled for the virtual server?"
  type        = bool
  default     = true
}

variable "application_profile_path" {
  description = "Application profile path for this virtual server. Note that this also differentiates between Layer 4 TCP/UDP and Layer 7 HTTP virtual servers."
  type        = string
}

variable "default_pool_member_ports" {
  description = ""
  type        = list(string)
  default     = []
}

variable "resource_description" {
  description = "A string added to the description field of all created resources"
  type        = string
  default     = "Terraform provisioned"
}

variable "display_name" {
  description = "The name of the LB Virtual Server"
  type        = string
}

variable "enabled" {
  description = "Should the virtual server be enabled"
  type        = bool
  default     = true
}

variable "ip_address" {
  description = "IP Address for the virtual server."
  type        = string
}

variable "log_significant_event_only" {
  description = "Should signficant events be logged to the access log. Requires `access_log_enabled` be true"
  type        = bool
  default     = null
}

variable "max_concurrent_connections" {
  description = "Maximum concurrent connections for the virtual server"
  type        = number
  default     = null
}

variable "max_new_connection_rate" {
  description = "New connection rate limit for the virtual server"
  type        = number
  default     = null
}

variable "persistence_profile_path" {
  description = "NSX resource path to a persistence profile which defines connection persistence for this virtual server"
  type        = string
  default     = null
}

variable "pool_path" {
  description = "NSX resource path to the load balancer pool which will service requests"
  type        = string
  default     = null
}

variable "ports" {
  description = "Ports the virtual server will listen on."
  type        = list(string)
}

variable "rules_defaults" {
  type = map(object({
    match_strategy = string
    phase          = string
    actions = list(object({
      http_redirect = optional(object({
        redirect_status = string
        redirect_url    = string
      }))
      http_reject = object({
        reply_status  = string
        reply_message = optional(string)
      })
      select_pool = object({
        poolid = string
      })
      variable_persistence_on = object({
        variable_name            = string
        variable_hash_enabled    = bool
        persistence_profile_path = string
      })
      http_response_header_rewrite = object({
        header_name  = string
        header_value = string
      })
      http_response_header_delete = object({
        header_name = string
      })
      http_response_header_delete = object({
        header_name = string
      })
      variable_persistence_learn = object({
        variable_name            = string
        variable_hash_enabled    = bool
        persistence_profile_path = string
      })
      http_request_uri_rewrite = object({
        uri           = string
        uri_arguments = string
      })
      http_request_header_rewrite = object({
        header_name  = string
        header_value = string
      })
      http_request_header_delete = object({
        header_name = string
      })
      variable_assignment = object({
        variable_name  = string
        variable_value = string
      })
      jwt_auth = object({
        key = object({
          certificate_path   = string
          public_key_content = string

        })
        pass_jwt_to_pool = bool
        realm            = string
        tokens           = list(string)
      })
      ssl_mode_selection = object({
        ssl_mode = string
      })
      connection_drop = any
    }))
    conditions = list(object({
      http_request_method = object({
        method  = string
        inverse = bool
      })
      http_request_version = object({
        version = string
        inverse = bool
      })
      ip_header = object({
        source_header = string
        group_path    = string
        inverse       = bool
      })
      tcp_header = object({
        source_header = string
        inverse       = bool
      })
      http_request_header = object({
        header_name    = string
        header_value   = string
        match_type     = string
        case_sensitive = bool
        inverse        = bool
      })
      http_respone_header = object({
        header_name    = string
        header_value   = string
        match_type     = string
        case_sensitive = bool
        inverse        = bool
      })
      variable = object({
        variable_name  = string
        variable_value = string
        match_type     = string
        case_sensitive = bool
        inverse        = bool
      })
      http_request_cookie = object({
        cookie_name    = string
        cookie_value   = string
        match_type     = string
        case_sensitive = bool
        inverse        = bool
      })
      http_request_body = object({
        body_value     = string
        match_type     = string
        case_sensitive = bool
        inverse        = bool
      })
      ssl_sni = object({
        sni            = string
        match_type     = string
        case_sensitive = bool
        inverse        = bool
      })
      http_ssl = object({
        client_certificate_issuer_dn = object({
          issuer_dn      = string
          match_type     = string
          case_sensitive = bool
        })
        client_certificate_subject_dn = object({
          subject_dn     = string
          match_type     = string
          case_sensitive = bool
        })
        client_supported_ssl_ciphers = list(string)
        session_reused               = string
        used_protocol                = string
        used_ssl_cipher              = string
        inverse                      = bool
      })
      http_request_uri = object({
        uri            = string
        match_type     = string
        case_sensitive = bool
        inverse        = bool
      })
      http_request_uri = object({
        uri_arguments  = string
        match_type     = string
        case_sensitive = bool
        inverse        = bool
      })
    }))
  }))
  default = {}
}

variable "rules" {}

variable "client_ssl" {
  type = object({
    default_certificate_path = string
    client_auth              = optional(string)
    certificate_chain_depth  = optional(number)
    ca_paths                 = optional(list(string))
    crl_paths                = optional(list(string))
    sni_paths                = optional(list(string))
    ssl_profile_path         = optional(string)
  })
  default = null
}

variable "server_ssl" {
  type = object({
    certificate_chain_depth = optional(number)
    client_certificate_path = optional(string)
    server_auth             = optional(string)
    ca_paths                = optional(list(string))
    crl_paths               = optional(list(string))
    ssl_profile_path        = optional(string)
  })
  default = null
}

variable "access_list_control" {
  type = object({
    enabled    = optional(string)
    action     = string
    group_path = string
  })
  default = null
}

variable "service_path" {
  description = "The load balancer service to associate this virtual server with"
  type        = string
  default     = null
}

variable "sorry_pool_path" {
  description = "The NSX resource path to a load balancer pool to service requests when the main pool is unavailable"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of NSX-T tag:scope pairs"
  type        = map(string)
  default     = {}
}
