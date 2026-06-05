# ── Terraform: provision a GCP VM to run the ELK Docker stack ──────────────
# Read top to bottom — each block creates one real thing in Google Cloud.

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# The provider = which cloud, which account/project, where.
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Turn on the Compute Engine API for this project (needed before making VMs).
# Terraform will enable it for you instead of you clicking in the console.
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# ── The VM itself ──────────────────────────────────────────────────────────
resource "google_compute_instance" "elk" {
  name         = "elk-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["elk"] # used by the firewall rules below to target this VM

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size_gb
    }
  }

  # Default network + an external IP so you can reach Kibana from your laptop.
  network_interface {
    network = "default"
    access_config {} # empty block = give it an ephemeral public IP
  }

  # Runs once on first boot: installs Docker and sets the kernel tweak
  # Elasticsearch requires. VM comes up ready to `docker compose up`.
  metadata_startup_script = file("${path.module}/startup-script.sh")

  depends_on = [google_project_service.compute]
}

# ── Firewall: only YOUR IP can reach SSH / Kibana / Elasticsearch ──────────
# Elasticsearch here has security disabled, so we must NOT open it to the
# world (open ES instances get wiped by bots within hours). Lock to your IP.

resource "google_compute_firewall" "ssh" {
  name          = "elk-allow-ssh"
  network       = "default"
  target_tags   = ["elk"]
  source_ranges = [var.my_ip_cidr]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "elk_ports" {
  name          = "elk-allow-kibana-es"
  network       = "default"
  target_tags   = ["elk"]
  source_ranges = [var.my_ip_cidr]
  allow {
    protocol = "tcp"
    ports    = ["5601", "9200"]
  }
  depends_on = [google_project_service.compute]
}
