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

variable "nsxt_load_balancer_virtual_server_config" {
  description = "NSXT Load Balancer Virtual Server Config"
  type = object({
    display_name               = string
    enabled                    = bool
    access_log_enabled         = bool
    log_significant_event_only = bool
    ip_address                 = string
    ports                      = list(number)
    default_pool_member_ports  = list(number)
    persistence_profile_path   = string
    max_concurrent_connections = number
    max_new_connection_rate    = number
    tags                       = map(string)
    access_list_control = object({
      enabled    = bool
      action     = string
      group_path = string
    })
    client_ssl = optional(object({
      default_certificate_path = string
      client_auth              = string
      certificate_chain_depth  = number
      ca_paths                 = list(string)
      crl_paths                = optional(list(string))
      sni_paths                = optional(list(string))
      ssl_profile_path         = string
    }))
    server_ssl = optional(object({
      server_auth             = string
      certificate_chain_depth = number
      ca_paths                = list(string)
      client_certificate_path = string
      ssl_profile_path        = string
    }))
    rules = map(object({
      match_strategy = optional(string)
      phase          = optional(string)
      actions = list(object({
        http_redirect = optional(object({
          redirect_status = string
          redirect_url    = string
        }))
        http_reject = optional(object({
          reply_status  = string
          reply_message = optional(string)
        }))
        select_pool = optional(object({
          pool_id = string
        }))
        variable_persistence_on = optional(object({
          variable_name            = string
          variable_hash_enabled    = optional(bool)
          persistence_profile_path = optional(string)
        }))
        http_response_header_rewrite = optional(object({
          header_name  = string
          header_value = string
        }))
        http_response_header_delete = optional(object({
          header_name = string
        }))
        variable_persistence_learn = optional(object({
          variable_name            = string
          variable_hash_enabled    = optional(bool)
          persistence_profile_path = optional(string)
        }))
        http_request_uri_rewrite = optional(object({
          uri           = string
          uri_arguments = optional(string)
        }))
        http_request_header_rewrite = optional(object({
          header_name  = string
          header_value = string
        }))
        http_request_header_delete = optional(object({
          header_name = string
        }))
        variable_assignment = optional(object({
          variable_name  = string
          variable_value = string
        }))
        jwt_auth = optional(object({
          key = object({
            certificate_path   = optional(string)
            public_key_content = optional(string)

          })
          pass_jwt_to_pool = optional(bool)
          realm            = optional(string)
          tokens           = optional(list(string))
        }))
        ssl_mode_selection = optional(object({
          ssl_mode = string
        }))
        connection_drop = optional(object({
          drop = bool
        }))
      }))
      conditions = optional(list(object({
        http_request_method = optional(object({
          method  = string
          inverse = optional(bool)
        }))
        http_request_version = optional(object({
          version = string
          inverse = optional(bool)
        }))
        ip_header = optional(object({
          source_address = string
          group_path     = optional(string)
          inverse        = optional(bool)
        }))
        tcp_header = optional(object({
          source_port = string
          inverse     = optional(bool)
        }))
        http_request_header = optional(object({
          header_name    = optional(string)
          header_value   = string
          match_type     = optional(string)
          case_sensitive = optional(bool)
          inverse        = optional(bool)
        }))
        http_respone_header = optional(object({
          header_name    = string
          header_value   = string
          match_type     = optional(string)
          case_sensitive = optional(bool)
          inverse        = optional(bool)
        }))
        variable = optional(object({
          variable_name  = string
          variable_value = string
          match_type     = optional(string)
          case_sensitive = optional(bool)
          inverse        = optional(bool)
        }))
        http_request_cookie = optional(object({
          cookie_name    = string
          cookie_value   = string
          match_type     = optional(string)
          case_sensitive = optional(bool)
          inverse        = optional(bool)
        }))
        http_request_body = optional(object({
          body_value     = string
          match_type     = optional(string)
          case_sensitive = optional(bool)
          inverse        = optional(bool)
        }))
        ssl_sni = optional(object({
          sni            = string
          match_type     = optional(string)
          case_sensitive = optional(bool)
          inverse        = optional(bool)
        }))
        http_ssl = optional(object({
          client_certificate_issuer_dn = optional(object({
            issuer_dn      = string
            match_type     = optional(string)
            case_sensitive = optional(bool)
          }))
          client_certificate_subject_dn = optional(object({
            subject_dn     = string
            match_type     = optional(string)
            case_sensitive = optional(bool)
          }))
          client_supported_ssl_ciphers = optional(list(string))
          session_reused               = optional(string)
          used_protocol                = optional(string)
          used_ssl_cipher              = optional(string)
          inverse                      = optional(bool)
        }))
        http_request_uri = optional(object({
          uri            = string
          match_type     = optional(string)
          case_sensitive = optional(bool)
          inverse        = optional(bool)
        }))
        http_request_uri_arguments = optional(object({
          uri_arguments  = string
          match_type     = optional(string)
          case_sensitive = optional(bool)
          inverse        = optional(bool)
        }))
      })))
    }))
  })
}