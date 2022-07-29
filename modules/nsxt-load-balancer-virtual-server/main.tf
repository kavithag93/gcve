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

locals {
  rules = merge(var.rules_defaults, var.rules)
  # These maps are not used but can serve as documentation for which actions are allowed with each phase
  phase_to_action_map = {
    HTTP_FORWARDING = [
      "http_reject",
      "http_redirect",
      "select_pool",
      "variable_persistence_on"
    ]
    HTTP_REQUEST_REWRITE = [
      "http_request_uri_rewrite",
      "http_request_header_rewrite",
      "http_request_header_delete",
      "variable_assignment"
    ]
    HTTP_RESPONSE_REWRITE = [
      "http_response_header_rewrite",
      "http_response_header_delete",
      "variable_persistence_learn"
    ]
    HTTP_ACCESS = ["jwt_auth"]
    TRANSPORT   = ["ssl_mode_selection"]
  }
  phase_to_condition_map = {
    HTTP_FORWARDING = [
      "http_request_method",
      "http_request_uri",
      "http_request_uri_arguments",
      "http_request_version",
      "http_request_header",
      "http_request_cookie",
      "http_request_body",
      "tcp_header",
      "ip_header",
      "variable",
      "http_ssl",
      "ssl_sni"
    ]
    HTTP_REQUEST_REWRITE = [
      "http_request_method",
      "http_request_uri",
      "http_request_uri_arguments",
      "http_request_version",
      "http_request_header",
      "http_request_cookie",
      "http_request_body",
      "tcp_header",
      "ip_header",
      "variable",
      "http_ssl"
    ]
    HTTP_RESPONSE_REWRITE = [
      "http_response_header",
      "http_request_method",
      "http_request_uri",
      "http_request_uri_arguments",
      "http_request_version",
      "http_request_header",
      "http_request_cookie",
      "http_request_body",
      "tcp_header",
      "ip_header",
      "variable",
      "http_ssl"
    ]
    HTTP_ACCESS = [
      "http_request_method",
      "http_request_uri",
      "http_request_uri_arguments",
      "http_request_version",
      "http_request_header",
      "http_request_cookie",
      "http_request_body",
      "tcp_header",
      "ip_header",
      "variable",
      "http_ssl"
    ]
    TRANSPORT = ["ssl_sni"]
  }
}

resource "nsxt_policy_lb_virtual_server" "this" {
  access_log_enabled         = var.access_log_enabled
  application_profile_path   = var.application_profile_path
  display_name               = var.display_name
  default_pool_member_ports  = var.default_pool_member_ports
  description                = var.resource_description
  enabled                    = var.enabled
  ip_address                 = var.ip_address
  log_significant_event_only = var.log_significant_event_only
  max_concurrent_connections = var.max_concurrent_connections
  max_new_connection_rate    = var.max_new_connection_rate
  persistence_profile_path   = var.persistence_profile_path
  pool_path                  = var.pool_path
  ports                      = var.ports
  service_path               = var.service_path
  sorry_pool_path            = var.sorry_pool_path

  dynamic "tag" {
    for_each = try(var.tags, {})
    content {
      tag   = tag.key
      scope = tag.value
    }
  }

  dynamic "access_list_control" {
    for_each = var.access_list_control == null ? [] : [true]
    content {
      action     = var.access_list_control.action
      group_path = var.access_list_control.group_path
      enabled    = try(var.access_list_control.enabled, null)
    }
  }

  dynamic "client_ssl" {
    for_each = var.client_ssl == null ? [] : [true]
    content {
      client_auth              = try(var.client_ssl.client_auth, null)
      default_certificate_path = var.client_ssl.default_certificate_path
      ca_paths                 = try(var.client_ssl.ca_paths, null)
      certificate_chain_depth  = try(var.client_ssl.certificate_chain_depth, null)
      ssl_profile_path         = try(var.client_ssl.ssl_profile_path, null)
      crl_paths                = try(var.client_ssl.crl_paths, null)
      sni_paths                = try(var.client_ssl.sni_paths, null)
    }
  }

  dynamic "server_ssl" {
    for_each = var.server_ssl == null ? [] : [true]
    content {
      server_auth             = try(var.server_ssl.server_auth, null)
      certificate_chain_depth = try(var.server_ssl.certificate_chain_depth, null)
      ca_paths                = try(var.server_ssl.ca_paths, null)
      client_certificate_path = try(var.server_ssl.client_certificate_path, null)
      crl_paths               = try(var.server_ssl.crl_paths, null)
      ssl_profile_path        = try(var.server_ssl.ssl_profile_path, null)
    }
  }

  // Terraform updates don't seem to apply. Seems to be a provider bug
  dynamic "rule" {
    for_each = try(var.rules, {})
    content {
      display_name   = rule.key
      match_strategy = try(rule.value.match_strategy)
      phase          = try(rule.value.phase)
      dynamic "action" {
        for_each = rule.value.actions
        # for_each = { for k, v in rule.value.actions : k => v }
        # for_each = { for k,v in rule.value.actions : k => v if contains(local.phase_to_action_map[rule.value.phase], v)}
        # for_each = { for a in rule.value.actions : a.type => a... if contains(local.phase_to_action_map[rule.value.phase], a.type) }
        content {
          dynamic "http_redirect" {
            iterator = item
            for_each = can(action.value.http_redirect) ? action.value : {}
            content {
              redirect_status = item.value.redirect_status
              redirect_url    = item.value.redirect_url
            }
          }
          dynamic "http_reject" {
            iterator = item
            for_each = can(action.value.http_reject) ? action.value : {}
            content {
              reply_status  = item.value.reply_status
              reply_message = try(item.value.reply_message, null)
            }
          }
          dynamic "select_pool" {
            iterator = item
            for_each = can(action.value.select_pool) ? action.value : {}
            content {
              pool_id = item.value.pool_id
            }
          }
          dynamic "connection_drop" {
            for_each = can(action.value.connection_drop) ? action.value : {}
            content {
            }
          }
          dynamic "variable_persistence_on" {
            iterator = item
            for_each = can(action.value.variable_persistence_on) ? action.value : {}
            content {
              variable_name            = item.value.variable_name
              variable_hash_enabled    = try(item.value.variable_hash_enabled, null)
              persistence_profile_path = try(item.value.persistence_profile_path, null)
            }
          }
          dynamic "http_response_header_rewrite" {
            iterator = item
            for_each = can(action.value.http_response_header_rewrite) ? action.value : {}
            content {
              header_name  = item.value.header_name
              header_value = item.value.header_value
            }
          }
          dynamic "http_response_header_delete" {
            iterator = item
            for_each = can(action.value.http_response_header_delete) ? action.value : {}
            content {
              header_name = item.value.header_name
            }
          }
          dynamic "variable_persistence_learn" {
            iterator = item
            for_each = can(action.value.variable_persistence_learn) ? action.value : {}
            content {
              variable_name            = item.value.variable_name
              persistence_profile_path = try(item.value.persistence_profile_path, null)
              variable_hash_enabled    = try(item.value.variable_hash_enabled, null)
            }
          }
          dynamic "http_request_uri_rewrite" {
            iterator = item
            for_each = can(action.value.http_request_uri_rewrite) ? action.value : {}
            content {
              uri           = item.value.uri
              uri_arguments = try(item.value.uri_arguments, null)
            }
          }
          dynamic "http_request_header_rewrite" {
            iterator = item
            for_each = can(action.value.http_request_header_rewrite) ? action.value : {}
            content {
              header_name  = item.value.header_name
              header_value = item.value.header_value
            }
          }
          dynamic "http_request_header_delete" {
            iterator = item
            for_each = can(action.value.http_request_header_delete) ? action.value : {}
            content {
              header_name = item.value.header_name
            }
          }
          dynamic "variable_assignment" {
            iterator = item
            for_each = can(action.value.variable_assignment) ? action.value : {}
            content {
              variable_name  = item.value.variable_name
              variable_value = item.value.variable_value
            }
          }
          dynamic "ssl_mode_selection" {
            iterator = item
            for_each = can(action.value.ssl_mode_selection) ? action.value : {}
            content {
              ssl_mode = item.value.ssl_mode
            }
          }
          dynamic "jwt_auth" {
            iterator = item
            for_each = can(action.value.jwt_auth) ? action.value : {}
            content {
              key {
                certificate_path   = try(item.value.key.certificate_path, null)
                public_key_content = try(item.value.key.public_key_content, null)
              }
              pass_jwt_to_pool = try(item.value.pass_jwt_to_pool, null)
              # realm            = try(item.value.realm, null)
              realm  = jsonencode(rule)
              tokens = try(item.value.tokens, null)
            }
          }
        }
      }
      # // This is the api match_conditions
      dynamic "condition" {
        for_each = try(rule.value.condition, {})
        content {
          dynamic "http_request_method" {
            iterator = item
            for_each = can(condition.value.http_request_method) ? condition.value : {}
            content {
              method  = item.value.method
              inverse = try(item.value.inverse, null)
            }
          }
          dynamic "http_request_uri" {
            iterator = item
            for_each = can(condition.value.http_request_uri) ? condition.value : {}
            content {
              uri            = item.value.uri
              match_type     = try(item.value.match_type, null) # Provider default is REGEX
              case_sensitive = try(item.value.case_sensitive, null)
              inverse        = try(item.value.inverse, null)
            }
          }
          dynamic "http_request_uri_arguments" {
            iterator = item
            for_each = can(condition.value.http_request_uri_arguments) ? condition.value : {}

            content {
              uri_arguments  = item.value.uri_arguments
              match_type     = try(item.value.match_type, null) # Provider default is REGEX
              case_sensitive = try(item.value.case_sensitive, null)
              inverse        = try(item.value.inverse, null)
            }
          }
          dynamic "http_request_version" {
            iterator = item
            for_each = can(condition.value.http_request_version) ? condition.value : {}
            content {
              version = item.value.version
              inverse = try(item.value.inverse, null)
            }
          }
          dynamic "http_request_header" {
            iterator = item
            for_each = can(condition.value.http_request_header) ? condition.value : {}
            content {
              header_name    = item.value.header_name
              header_value   = item.value.header_value
              match_type     = try(item.value.match_type, null) # Provider default is REGEX
              case_sensitive = try(item.value.case_sensitive, null)
              inverse        = try(item.value.inverse, null)
            }
          }
          dynamic "http_response_header" {
            iterator = item
            for_each = can(condition.value.http_response_header) ? condition.value : {}
            content {
              header_name    = try(item.value.header_name, null) # Provider default is Host
              header_value   = item.value.header_value
              match_type     = try(item.value.match_type, null) # Provider default is REGEX
              case_sensitive = try(item.value.case_sensitive, null)
              inverse        = try(item.value.inverse, null)
            }
          }
          dynamic "http_request_body" {
            iterator = item
            for_each = can(condition.value.http_request_body) ? condition.value : {}
            content {
              body_value     = item.value.body_value
              match_type     = try(item.value.match_type) # Provider default is REGEX
              case_sensitive = try(item.value.case_sensitive, null)
              inverse        = try(item.value.inverse, null)
            }
          }
          dynamic "http_request_cookie" {
            iterator = item
            for_each = can(condition.value.http_request_cookie) ? condition.value : {}
            content {
              cookie_name    = item.value.cookie_name
              cookie_value   = item.value.cookie_value
              match_type     = try(item.value.match_type, null) # Provider default is REGEX
              case_sensitive = try(item.value.case_sensitive, null)
              inverse        = try(item.value.inverse, null)
            }
          }
          dynamic "tcp_header" {
            iterator = item
            for_each = can(condition.value.tcp_header) ? condition.value : {}
            content {
              source_port = item.value.source_port
              inverse     = try(item.value.inverse, null)
            }
          }
          dynamic "ip_header" {
            iterator = item
            for_each = can(condition.value.ip_header) ? condition.value : {}
            content {
              source_address = item.value.source_address
              group_path     = try(item.value.group_path, null)
              inverse        = try(item.value.inverse, null)
            }
          }
          dynamic "variable" {
            iterator = item
            for_each = can(condition.value.variable) ? condition.value : {}
            content {
              variable_name  = item.value.variable_name
              variable_value = item.value.variable_value
              match_type     = try(item.value.match_type, null) # Provider default is REGEX
              case_sensitive = try(item.value.case_sensitive, null)
              inverse        = try(item.value.inverse, null)
            }
          }
          dynamic "http_ssl" {
            iterator = item
            for_each = can(condition.value.http_ssl) ? condition.value : {}
            content {
              dynamic "client_certificate_issuer_dn" {
                for_each = can(item.value.client_certificate_issuer_dn) ? [item.value.client_certificate_issuer_dn] : []
                content {
                  issuer_dn      = client_certificate_issuer_dn.value.issuer_dn
                  case_sensitive = try(client_certificate_issuer_dn.value.case_sensitive, null)
                  match_type     = try(client_certificate_issuer_dn.value.match_type, null) # Provider default is REGEX
                }
              }
              dynamic "client_certificate_subject_dn" {
                for_each = can(item.value.client_certificate_subject_dn) ? [item.value.client_certificate_subject_dn] : []
                content {
                  subject_dn     = client_certificate_subject_dn.value.subject_dn
                  case_sensitive = try(client_certificate_subject_dn.value.case_sensitive, null)
                  match_type     = try(client_certificate_subject_dn.value.match_type, null) # Provider default is REGEX
                }
              }
              client_supported_ssl_ciphers = try(item.value.client_supported_ssl_ciphers, null)
              used_ssl_cipher              = try(item.value.used_ssl_cipher, null)
              session_reused               = try(item.value.session_reused, null)
              used_protocol                = try(item.value.used_protocol, null)
            }
          }
          dynamic "ssl_sni" {
            iterator = item
            for_each = can(condition.value.ssl_sni) ? condition.value : {}
            content {
              sni            = item.value.sni
              match_type     = try(item.value.match_type, null) # Provider default is REGEX
              case_sensitive = try(item.value.case_sensitive, null)
              inverse        = try(item.value.inverse, null)
            }
          }
        }
      }
      # }
      # }
    }
  }
}
