############################################################################################
# Copyright 2020 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################

// Network

resource "google_compute_network" "vpc" {
  name                    = var.cluster_network_name
  auto_create_subnetworks = "false"
}

// Subnet

resource "google_compute_subnetwork" "subnet" {
  name          = var.cluster_subnetwork_name
  network       = var.cluster_network_name
  ip_cidr_range = var.cluster_subnetwork_cidr_range

  // Secondary ranges

  secondary_ip_range {
    range_name    = var.cluster_secondary_range_name
    ip_cidr_range = var.cluster_secondary_range_cidr
  }

  secondary_ip_range {
    range_name    = var.services_secondary_range_name
    ip_cidr_range = var.services_secondary_range_cidr
  }

  depends_on = [
    google_compute_network.vpc,
  ]
}

// Firewall rule

resource "google_compute_firewall" "firewall" {
  name        = "panorama-allow-inbound"
  description = var.firewall_name
  network     = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "3978", "28433"]
  }

  source_ranges = ["0.0.0.0/0"]
}