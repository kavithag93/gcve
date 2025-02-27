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

project_id           = ""
repo_name            = "gcve-iac-foundations"
repo_owner           = "GoogleCloudPlatform"
gh_token             = ""
create_network       = false
create_subnetwork    = false
instance_name        = ""
machine_type         = "t2d-standard-1"
region               = "asia-southeast1"
zone                 = "asia-southeast1-b"
max_replicas         = 1
min_replicas         = 1
network_name         = "gcve-vpc-net"
subnet_name          = "gcve-asia-southeast1-connection-subnet"
source_image_project = "ubuntu-os-cloud"
source_image_family  = "ubuntu-2204-lts"
