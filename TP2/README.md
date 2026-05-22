# TP2 - DevOps Infrastructure Automation With Terraform, Jinja2, and Ansible

This practical work automates a modular deployment of the TP1 Click Tracker application.
It uses Docker where it is useful for repeatable tooling, and VMs where the grading rubric
requires managed Linux and Windows targets. The default grading configuration requires at
least one Linux VM and one Windows VM, but additional targets can be added or disabled from
the target JSON configuration.

## Architecture

```text
GitHub private repository
        |
        v
Self-hosted GitHub Actions runner (exclusive executor, label: tp2)
        |
        +--> Dockerized Ansible controller
        |       |
        |       +--> Linux VM over SSH
        |       |       - facts
        |       |       - timezone changes
        |       |       - Docker Compose deployment of TP1
        |       |
        |       +--> Windows VM over WinRM
        |               - facts
        |               - timezone changes
        |               - Docker Compose deployment of TP1
        |
        +--> Terraform metadata stage
                |
                +--> Jinja2 inventory rendering
```

Cloud-ready placeholders are kept in Terraform through `cloud_ready_providers`
for AWS, GCP, Azure, and Alibaba alignment. The current implementation does not
create cloud resources; it prepares normalized target metadata for Ansible.

## Requirements

### Self-hosted GitHub Actions runner

Register a self-hosted runner for this repository with these labels:

```text
self-hosted
linux
x64
tp2
```

The TP2 workflow uses only:

```yaml
runs-on: [self-hosted, linux, x64, tp2]
```

This proves the custom local runner is the exclusive pipeline executor.

### Linux target VM

Recommended OS: Ubuntu Server.

Required:

- SSH reachable from the runner host.
- User with passwordless sudo.
- Python 3 installed.

Ansible installs Docker Engine and Docker Compose plugin if they are missing.

### Windows target VM

Recommended OS: Windows 11 or Windows Server.

Required:

- WinRM HTTPS reachable from the runner host, default port `5986`.
- Docker Desktop or Docker Engine already installed.
- Docker configured in Linux-container mode.
- The configured Windows user can run Docker commands.

Docker Desktop installation is intentionally manual because it is interactive
and less reliable to automate in a grading lab.

## GitHub Secrets

Create these repository secrets:

```text
TP2_TARGETS_JSON
TP2_LINUX_SSH_KEYS_JSON
TP2_WINDOWS_PASSWORDS_JSON
```

`TP2_TARGETS_JSON` uses the same shape as `TP2/targets.auto.tfvars.json.example`:

```json
{
  "targets": {
    "linux1": {
      "enabled": true,
      "os": "linux",
      "host": "192.0.2.10",
      "user": "ubuntu",
      "port": 22,
      "auth_ref": "linux1",
      "deploy_path": "/opt/clicktracker/TP1"
    },
    "windows1": {
      "enabled": true,
      "os": "windows",
      "host": "192.0.2.20",
      "user": "Administrator",
      "port": 5986,
      "auth_ref": "windows1",
      "deploy_path": "C:\\clicktracker\\TP1"
    }
  }
}
```

`TP2_LINUX_SSH_KEYS_JSON` maps each Linux target `auth_ref` to its private key:

```json
{
  "linux1": "-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----"
}
```

`TP2_WINDOWS_PASSWORDS_JSON` maps each Windows target `auth_ref` to its password:

```json
{
  "windows1": "change-me"
}
```

Add or remove a target by editing the `targets` map. To keep a target documented but
temporarily exclude it from deployment, set `"enabled": false`.

## Pipeline Flow

The workflow is `.github/workflows/tp2-automation.yml`.

It runs when `TP2/**`, `TP1/**`, or the workflow itself changes.

Jobs:

1. `runner-proof`
   - prints runner name, OS, architecture, hostname, workspace, and repository.
   - this is the screenshot proof that the custom self-hosted runner executed the job.

2. `terraform-inventory`
   - runs Terraform format, init, validate, plan, and metadata apply.
   - writes `TP2/generated/targets.auto.tfvars.json` from `TP2_TARGETS_JSON`.
   - writes per-target Linux SSH key files under `TP2/generated/keys/`.
   - exports `TP2/generated/targets.json`.
   - renders `TP2/generated/inventory.yml` using `TP2/templates/inventory.yml.j2`.
   - uploads generated inventory as a pipeline artifact.

3. `ansible-automation`
   - runs Ansible inside the Dockerized controller.
   - syntax-checks the full playbook.
   - gathers facts on controller, Linux VM, and Windows VM.
   - changes Linux and Windows timezones to Europe/Paris, verifies them, then changes them to Africa/Abidjan, and verifies again.
   - deploys TP1 to both target VMs.
   - validates frontend, backend, Prometheus, and Grafana endpoints.

## Local Static Checks

From the repository root:

```bash
docker compose -f TP2/docker-compose.yml config
terraform -chdir=TP2/terraform fmt -check
terraform -chdir=TP2/terraform validate
```

To build the Ansible controller:

```bash
docker compose -f TP2/docker-compose.yml build ansible-controller
```

To render a sample inventory locally, copy `TP2/targets.auto.tfvars.json.example`
to `TP2/targets.auto.tfvars.json`, adjust target addresses, then run:

```bash
terraform -chdir=TP2/terraform init
terraform -chdir=TP2/terraform apply -var-file=../targets.auto.tfvars.json -auto-approve
terraform -chdir=TP2/terraform output -json target_metadata > TP2/generated/targets.json
docker compose -f TP2/docker-compose.yml run --rm ansible-controller \
  python3 TP2/scripts/render_inventory.py \
  TP2/generated/targets.json \
  TP2/templates/inventory.yml.j2 \
  TP2/generated/inventory.yml
```

Then syntax-check:

```bash
docker compose -f TP2/docker-compose.yml run --rm ansible-controller \
  ansible-playbook \
  -i TP2/generated/inventory.yml \
  TP2/ansible/playbooks/site.yml \
  --syntax-check
```

## Deployment Validation

The pipeline validates these endpoints for every enabled target:

- frontend: `http://TARGET_HOST:5173`
- backend: `POST http://TARGET_HOST:8080/api/click`
- Prometheus: `http://TARGET_HOST:9090/-/ready`
- Grafana: `http://TARGET_HOST:3000/api/health`

## Stopping TP1

After generating inventory, run:

```bash
docker compose -f TP2/docker-compose.yml run --rm ansible-controller \
  ansible-playbook \
  -i TP2/generated/inventory.yml \
  TP2/ansible/playbooks/stop_tp1.yml
```

## Expected Screenshot Proofs

Store final evidence in `TP2/proof_of_execution/`.

Recommended screenshots:

1. GitHub repository runner settings showing the registered self-hosted runner and `tp2` label.
2. Successful TP2 pipeline overview.
3. `runner-proof` logs showing `RUNNER_NAME`, `RUNNER_OS`, hostname, and workspace.
4. Terraform/Jinja2 stage logs showing generated `targets.json` and `inventory.yml`.
5. Ansible facts output for controller, Linux VM, and Windows VM.
6. Linux timezone verification logs.
7. Windows timezone verification logs.
8. TP1 validation logs for every enabled target.

## Delivery Naming

Use the exact filename required by the assignment, replacing the name fields:

```text
LASTNAME Firstname - DevOps M1-DEV1 2026 - 09-04-2026.zip
```

Include:

- Git repository content.
- `TP1/`
- `TP2/`
- `.github/workflows/`
- `TP2/proof_of_execution/`
- this README.
