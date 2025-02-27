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




module "zone1" {
  source                       = "../../modules/t1-zone/"
  t1_name                      = "t1-production"
  edge_cluster_path            = data.nsxt_policy_edge_cluster.edge-cluster.path
  t0_path                      = data.nsxt_policy_tier0_gateway.tier0_gw_gateway.path
  t1_description               = "T1  Logical Router for Production"
  t1_failover_mode             = "PREEMPTIVE"
  t1_default_rule_logging      = "false"
  t1_enable_firewall           = "true"
  t1_enable_standby_relocation = "false"
  t1_route_advertisement_types = ["TIER1_CONNECTED"]
  t1_pool_allocation           = "ROUTING"
  overlay_tz_path              = data.nsxt_policy_transport_zone.overlay_tz.path
  segments = {
    zone1-segment1 = {
      display_name = "prod frontend segment"
      description  = "This is the prod frontend segment"
      subnet = {
        cidr = "10.49.128.1/24"
      }
    },
    zone1-segment2 = {
      display_name = "prod backend segment"
      description  = "This is the prod backend segment"
      subnet = {
        cidr = "10.49.129.1/24"
      }
    },

  }
  gwf_policies = [

    {
      display_name    = "gwf_allow_policy"
      sequence_number = 1000
      rules = [
        {
          action             = "ALLOW"
          destination_groups = ["10.123.1.0/24"]
          source_groups      = ["10.100.0.0-10.100.0.128"]
          direction          = "IN_OUT"
          display_name       = "gwf-allow-ssh"
          logged             = false
          services           = ["SSH"]
        },
        {
          action             = "ALLOW"
          destination_groups = ["10.0.0.0/8"]
          source_groups      = []
          direction          = "IN_OUT"
          display_name       = "gfw-allow-internal"
          logged             = false
          services           = ["DNS", "HTTP"]
        },
      ]
    },
    {
      display_name    = "gwf_drop_policy"
      sequence_number = 4000
      rules = [
        {
          action             = "DROP"
          destination_groups = ["10.123.2.0/23"]
          source_groups      = []
          direction          = "IN"
          display_name       = "gfw-drop-all"
          logged             = false
          services           = []
        }
      ]
    },
  ]
}


module "zone2" {
  source                       = "../../modules/t1-zone/"
  t1_name                      = "t1-nonproduction"
  edge_cluster_path            = data.nsxt_policy_edge_cluster.edge-cluster.path
  t0_path                      = data.nsxt_policy_tier0_gateway.tier0_gw_gateway.path
  t1_description               = "L1 Logical router for zone 1"
  t1_failover_mode             = "PREEMPTIVE"
  t1_default_rule_logging      = "false"
  t1_enable_firewall           = "true"
  t1_enable_standby_relocation = "false"
  t1_route_advertisement_types = ["TIER1_CONNECTED"]
  t1_pool_allocation           = "ROUTING"
  overlay_tz_path              = data.nsxt_policy_transport_zone.overlay_tz.path
  segments = {
    zone2-segment1 = {
      display_name = "nonprod frontend segment"
      description  = "This is the nonprod frontend segment"
      subnet = {
        cidr = "10.49.132.1/24"
      }
    },
    zone2-segment2 = {
      display_name = "nonprod backend segment"
      description  = "This is the nonprod backend  segment"
      subnet = {
        cidr = "10.49.133.1/24"
      }
    }
  }
  gwf_policies = [
    {
      display_name    = "gwf_allow_policy"
      sequence_number = 1000
      rules = [
        {
          action             = "ALLOW"
          destination_groups = ["10.123.1.0/24"]
          source_groups      = ["10.100.0.0-10.100.0.128"]
          direction          = "IN_OUT"
          display_name       = "gwf-allow-ssh"
          logged             = false
          services           = ["SSH"]
        },
        {
          action             = "ALLOW"
          destination_groups = ["10.0.0.0/8"]
          source_groups      = []
          direction          = "IN_OUT"
          display_name       = "gfw-allow-internal"
          logged             = false
          services           = ["DNS", "HTTP"]
        },
      ]
    },
    {
      display_name    = "gwf_drop_policy"
      sequence_number = 4000
      rules = [
        {
          action             = "DROP"
          destination_groups = ["10.123.2.0/23"]
          source_groups      = []
          direction          = "IN"
          display_name       = "gfw-drop-all"
          logged             = false
          services           = []
        }
      ]
    },
  ]
}
