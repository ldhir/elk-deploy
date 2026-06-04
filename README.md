# elk-deploy

ELK (Elasticsearch, Logstash, Kibana) deployment pipeline driven by **Jenkins** and **Ansible**.

## Layout

```
jenkins/
  Jenkinsfile              # declarative CI/CD pipeline (lint + deploy)
ansible/
  ansible.cfg
  site.yml                 # top-level playbook (all three components)
  inventory/
    staging.ini
    production.ini
  group_vars/
    all.yml                # shared, non-secret vars (versions, ports)
  roles/
    common/                # Elastic APT repo + prereqs
    elasticsearch/
    logstash/
    kibana/
```

## Deploy locally

```bash
cd ansible
ansible-playbook -i inventory/staging.ini site.yml
# single component:
ansible-playbook -i inventory/staging.ini site.yml --tags kibana
# dry run:
ansible-playbook -i inventory/staging.ini site.yml --check --diff
```

Fill in real hosts in `inventory/*.ini` first (placeholders are commented out).

## Jenkins

The pipeline expects two credentials on the controller:

| Credential ID       | Type              | Purpose                          |
|---------------------|-------------------|----------------------------------|
| `elk-ssh-key`       | SSH private key   | Reaching target hosts            |
| `ansible-vault-pass`| Secret text       | Ansible Vault password           |

`TARGET_ENV` (staging/production) and `CHECK_MODE` are build parameters.

## Secrets

Keys, certs, vault passwords, and `.env` files are git-ignored — see `.gitignore`.
Never commit `*.key` / `*.pem` or vault passwords. Put secrets in an Ansible Vault
file (e.g. `ansible/group_vars/all/vault.yml`) or a Jenkins credential.

> Security note: this scaffold disables X-Pack security for simplicity
> (`xpack.security.enabled: false`). Enable security + TLS before any real use.
