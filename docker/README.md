# ELK via Docker Compose

Run the whole ELK stack as containers on a Docker host (your VM).

## Layout

```
docker-compose.yml          elasticsearch + logstash + kibana
.env.example                versions, ports, heap (copy to .env)
logstash/pipeline/
  logstash.conf             Beats input -> Elasticsearch output
```

## Prereqs on the VM (do once)

1. **Install Docker + the compose plugin.** On Ubuntu:
   ```bash
   curl -fsSL https://get.docker.com | sh
   sudo usermod -aG docker $USER   # log out/in so you can run docker without sudo
   ```
2. **Set the kernel map-count** — Elasticsearch refuses to start without it:
   ```bash
   sudo sysctl -w vm.max_map_count=262144
   # make it survive reboots:
   echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-elastic.conf
   ```
   (On Docker Desktop / Mac this is handled for you — only matters on a Linux VM.)

## Run

```bash
cd docker
cp .env.example .env          # adjust ES_HEAP to the VM's RAM
docker compose up -d
docker compose ps             # wait for elasticsearch -> healthy
```

Then:
- Elasticsearch → `http://<vm-ip>:9200`
- Kibana → `http://<vm-ip>:5601`

> On Oracle free tier you must also **open ports 5601 / 9200 in the VCN
> security list / firewall** (and `ufw allow` on the box) or you won't reach
> them from your laptop.

## Common commands

```bash
docker compose logs -f kibana     # follow one service
docker compose restart logstash   # restart after editing the pipeline
docker compose down               # stop containers (keeps data volume)
docker compose down -v            # stop AND delete ES data
```

## Sizing note (free tier)

A full 3-container ELK stack is heavy for a 1GB VM. If Elasticsearch keeps
getting OOM-killed, either bump the VM RAM or run **Elasticsearch + Kibana
only** (drop Logstash and have Filebeat write straight to Elasticsearch).

## Security

`xpack.security.enabled=false` here for a frictionless first boot. Before any
real use: enable security, set passwords, add TLS, and put `.env` secrets in a
proper secret store. `.env` is git-ignored.

## Docker vs the Ansible path (../ansible)

Two ways to deploy the same stack:
- **Ansible** — installs ELK packages onto the VM's OS directly.
- **Docker** — runs each component as a container; nothing installed on the OS but Docker itself.

Docker is faster to stand up and tear down; Ansible gives finer host-level control. Same stack, your choice.
