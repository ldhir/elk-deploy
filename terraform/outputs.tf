# After `terraform apply`, these print so you know where things are.

output "external_ip" {
  description = "Public IP of the VM"
  value       = google_compute_instance.elk.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "Copy-paste to SSH in"
  value       = "gcloud compute ssh elk-vm --zone ${var.zone}"
}

output "kibana_url" {
  description = "Open this once the stack is up"
  value       = "http://${google_compute_instance.elk.network_interface[0].access_config[0].nat_ip}:5601"
}
