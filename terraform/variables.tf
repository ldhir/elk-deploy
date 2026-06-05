# Inputs to the config. Values come from terraform.tfvars (you create that).

variable "project_id" {
  description = "Your GCP project ID (gcloud projects list)"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form, e.g. 73.92.x.x/32 — locks the firewall to you"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-west1"
}

variable "zone" {
  description = "GCP zone (must be inside region)"
  type        = string
  default     = "us-west1-a"
}

variable "machine_type" {
  description = "VM size. e2-standard-2 = 2 vCPU / 8GB, comfortable for full ELK"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 30
}
