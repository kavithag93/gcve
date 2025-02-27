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

module "gcve_github_actions_runners" {
  source               = "github.com/terraform-google-modules/terraform-google-github-actions-runners//modules/gh-runner-mig-vm?ref=v3.1.0"
  create_network       = var.create_network
  create_subnetwork    = var.create_subnetwork
  project_id           = var.project_id
  repo_name            = var.repo_name
  repo_owner           = var.repo_owner
  gh_token             = var.gh_token
  instance_name        = var.instance_name
  machine_type         = var.machine_type
  region               = var.region
  zone                 = var.zone
  max_replicas         = var.max_replicas
  min_replicas         = var.min_replicas
  network_name         = var.network_name
  subnet_name          = var.subnet_name
  startup_script       = file("${path.cwd}/scripts/startup.sh")
  shutdown_script      = file("${path.cwd}/scripts/shutdown.sh")
  source_image_project = var.source_image_project
  source_image_family  = var.source_image_family
}

resource "null_resource" "wait_for_runner" {
  triggers = {
    always_run = "${timestamp()}"
    gh_token   = var.gh_token
    repo_owner = var.repo_owner
    repo_name  = var.repo_name
  }

  provisioner "local-exec" {
    command = <<EOT
    python3 ${path.module}/scripts/wait_for_runner.py \
        --auth_token ${var.gh_token} \
        --repo_owner ${var.repo_owner} \
        --repo ${var.repo_name} 
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    python3 ${path.module}/scripts/cleanup_gh_runners.py \
        --auth_token ${self.triggers.gh_token} \
        --repo_owner ${self.triggers.repo_owner} \
        --repo ${self.triggers.repo_name}
    EOT
  }

  depends_on = [
    module.gcve_github_actions_runners,
  ]
}