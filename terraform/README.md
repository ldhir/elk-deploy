# Terraform — provision the ELK VM on GCP

Creates an Ubuntu VM (Docker pre-installed via startup script), locked down to
your IP, ready to run the `../docker` stack.

## What gets created
- 1 × `e2-standard-2` VM named `elk-vm` (8GB RAM — comfortable for full ELK)
- Firewall rules opening **22 / 5601 / 9200 to your IP only**
- Compute Engine API enabled on the project

## One-time setup
```bash
# 1. Log in (interactive — opens a browser)
gcloud auth login
gcloud auth application-default login   # lets Terraform use your creds

# 2. Find your project ID
gcloud projects list

# 3. Fill in your values
cp terraform.tfvars.example terraform.tfvars
#   project_id = "..."         (from step 2)
#   my_ip_cidr = "$(curl -s ifconfig.me)/32"
```

## Provision
```bash
terraform init      # download the google provider
terraform plan      # preview — what WILL be created (read this!)
terraform apply     # type 'yes' to build it
```
Outputs print the VM's IP, an SSH command, and the Kibana URL.

## Deploy ELK on the VM
```bash
gcloud compute ssh elk-vm --zone us-west1-a
# on the VM (Docker + repo already there from the startup script):
cd elk-deploy/docker
cp .env.example .env
docker compose up -d
docker compose ps          # wait for elasticsearch = healthy
```
Then open the `kibana_url` from the Terraform output.

## Tear down (stop billing)
```bash
terraform destroy   # deletes the VM + firewall. Re-apply anytime.
```
Or just **stop** the VM in the console to pause compute billing while keeping the disk.

## The mental model
- **Terraform** built the VM (provisioning).
- **The startup script** installed Docker (configuration).
- **Docker Compose** runs ELK (the apps).
