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

data "nsxt_policy_service" "this" {
  depends_on = [nsxt_policy_service.this]

  # Lookup the NSX-T path for every service listed in all of the rules
  for_each     = toset(flatten(var.rules.*.services))
  display_name = each.value
}

resource "nsxt_policy_gateway_policy" "this" {
  depends_on   = [data.nsxt_policy_service.this]
  display_name = var.display_name
  description  = var.resource_description
  category     = "LocalGatewayRules"
  locked       = var.locked
  stateful     = var.stateful
  tcp_strict   = var.tcp_strict

  dynamic "rule" {
    for_each = var.rules[*]
    content {
      display_name       = rule.value.display_name
      destination_groups = rule.value.destination_groups
      disabled           = rule.value.disabled
      action             = upper(rule.value.action)
      direction          = upper(rule.value.direction)
      logged             = rule.value.logged
      scope              = [var.tier1_gateway_path]
      services           = [for s in rule.value.services : data.nsxt_policy_service.this[s].path]
    }
  }

  dynamic "tag" {
    for_each = try(var.tags, {})
    content {
      tag   = tag.key
      scope = tag.value
    }
  }
}

resource "nsxt_policy_service" "this" {
  for_each     = try(var.custom_l4_services, {})
  description  = var.resource_description
  display_name = each.key

  l4_port_set_entry {
    display_name      = each.key
    description       = try(each.value.description, null)
    protocol          = each.value.protocol
    destination_ports = each.value.destination_ports
    source_ports      = try(each.value.source_ports, null)
  }

  dynamic "tag" {
    for_each = each.value.tags == null ? {} : each.value.tags
    content {
      scope = tag.key
      tag   = tag.value
    }
  }
}
