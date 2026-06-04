# elk-deploy

ELK (Elasticsearch, Logstash, Kibana) deployment pipeline driven by **Jenkins** and **Ansible**.

## Layout

```
ansible/        # Ansible playbooks and roles for provisioning the ELK stack
  roles/        # one role per component (elasticsearch, logstash, kibana, beats)
jenkins/        # Jenkinsfile and CI/CD pipeline definitions
```

## Status

Scaffold. Pipeline files (Jenkinsfile, playbooks, inventory) to be added.

## Secrets

Keys, certs, vault passwords, and `.env` files are git-ignored — see `.gitignore`.
Never commit `*.key` / `*.pem` or Ansible Vault passwords. Use Ansible Vault or
Jenkins credentials for anything sensitive.
