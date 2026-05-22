# TP2 Setup Guide - GitHub Actions, Terraform, Jinja2, and Ansible

This folder contains the infrastructure automation project for TP2. It deploys the TP1 Click Tracker application to managed virtual machines using a self-hosted GitHub Actions runner, Terraform-generated metadata, Jinja2-rendered configuration, a Dockerized Ansible controller, and a Traefik load balancer.

The setup is modular: targets and public hostnames are configured from JSON, so Linux and Windows VMs can be added, removed, or temporarily disabled without changing the Ansible playbooks or Traefik routes.

## What You Will Build

```text
GitHub repository
        |
        v
Self-hosted GitHub Actions runner
labels: self-hosted, linux, x64, tp2
        |
        +--> Terraform metadata stage
        |       - validates target configuration
        |       - exports target metadata as JSON
        |
        +--> Jinja2 inventory rendering
        |       - creates TP2/generated/inventory.yml
        |       - creates TP2/generated/traefik/dynamic.yml
        |
        +--> Dockerized Ansible controller
                |
                +--> Linux VM over SSH
                |       - fact gathering
                |       - timezone management
                |       - TP1 Docker Compose deployment
                |
                +--> Windows VM over WinRM
                        - fact gathering
                        - timezone management
                        - TP1 Docker Compose deployment
                |
                +--> Traefik on the runner host
                        - middleware
                        - load balancing
                        - hostname routing to all enabled targets
```

For grading, keep at least one enabled Linux target and one enabled Windows target. Extra targets are supported.

## 1. Prepare The Runner Host

Use a Linux machine as the self-hosted GitHub Actions runner. This machine is also the Docker host that runs the Ansible controller container.

Install these tools on the runner host:

```bash
docker --version
docker compose version
terraform version
git --version
```

The runner host must be able to reach:

- the Linux VM over SSH, usually port `22`
- the Windows VM over WinRM HTTPS, usually port `5986`
- the deployed TP1 service ports on each VM:
  - frontend: `5173`
  - backend: `8080`
  - Prometheus: `9090`
  - Grafana: `3000`

The runner host also exposes Traefik:

- routed HTTP traffic: default port `80`
- Traefik dashboard: default port `8088`

Create DNS records or local `/etc/hosts` entries so the modular Traefik hostnames point to the runner host. For a lab setup, this is enough:

```text
RUNNER_HOST_IP app.runner.local api.runner.local prometheus.runner.local grafana.runner.local
```

## 2. Register The GitHub Actions Runner

In GitHub, open the repository settings:

```text
Settings -> Actions -> Runners -> New self-hosted runner
```

Follow the Linux registration instructions and add this custom label:

```text
tp2
```

The final runner labels must include:

```text
self-hosted
linux
x64
tp2
```

This is important because the TP2 workflow only uses:

```yaml
runs-on: [self-hosted, linux, x64, tp2]
```

That proves the custom runner is the exclusive pipeline executor.

## 3. Prepare The Linux Target VM

Recommended OS: Ubuntu Server.

Required setup:

- SSH is enabled.
- The runner host can connect to the VM.
- The SSH user has passwordless sudo.
- Python 3 is installed.

Example check from the runner host:

```bash
ssh ubuntu@LINUX_VM_IP "python3 --version && sudo -n true"
```

Ansible installs these Linux dependencies if they are missing:

- Docker Engine
- Docker Compose plugin
- Python 3
- rsync

Default TP1 deployment path:

```text
/opt/clicktracker/TP1
```

## 4. Prepare The Windows Target VM

Recommended OS: Windows 11 or Windows Server.

Required setup:

- WinRM HTTPS is enabled.
- The runner host can reach WinRM, usually port `5986`.
- Docker Desktop or Docker Engine is already installed.
- Docker is configured for Linux containers.
- The configured Windows user can run Docker commands.

Docker Desktop installation is intentionally manual because it is interactive and unreliable to automate in a lab environment.

On the Windows VM, verify Docker:

```powershell
docker version
docker compose version
```

Default TP1 deployment path:

```text
C:\clicktracker\TP1
```

## 5. Configure Targets

Targets are described in Terraform variable JSON. For local work, copy the example file:

```bash
cp TP2/targets.auto.tfvars.json.example TP2/targets.auto.tfvars.json
```

Edit `TP2/targets.auto.tfvars.json` with your VM addresses and users:

```json
{
  "load_balancer": {
    "enabled": true,
    "host": "runner.local",
    "http_port": 80,
    "dashboard_port": 8088,
    "hostnames": {
      "frontend": "app.runner.local",
      "backend": "api.runner.local",
      "prometheus": "prometheus.runner.local",
      "grafana": "grafana.runner.local"
    }
  },
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

Load balancer fields:

- `enabled`: set to `false` to skip Traefik startup and Traefik route validation.
- `host`: runner host address used by Ansible validation, for example `runner.local` or the runner IP.
- `http_port`: public Traefik HTTP port, default `80`.
- `dashboard_port`: public Traefik dashboard port, default `8088`.
- `hostnames`: public hostnames routed by Traefik.

Target fields:

- `enabled`: set to `false` to keep the target in the file but skip deployment.
- `os`: must be `linux` or `windows`.
- `host`: IP address or DNS name reachable from the runner.
- `user`: SSH or WinRM username.
- `port`: SSH port for Linux, WinRM HTTPS port for Windows.
- `auth_ref`: key used to find credentials in the GitHub secrets.
- `deploy_path`: directory where TP1 is copied on the VM.

To add another Linux VM, add another entry:

```json
"linux2": {
  "enabled": true,
  "os": "linux",
  "host": "192.0.2.11",
  "user": "debian",
  "port": 22,
  "auth_ref": "linux2",
  "deploy_path": "/opt/clicktracker/TP1"
}
```

## 6. Configure GitHub Secrets

Create these repository secrets:

```text
TP2_TARGETS_JSON
TP2_LINUX_SSH_KEYS_JSON
TP2_WINDOWS_PASSWORDS_JSON
```

Open:

```text
Settings -> Secrets and variables -> Actions -> New repository secret
```

### `TP2_TARGETS_JSON`

Use the same content as `TP2/targets.auto.tfvars.json`, adjusted for your real VMs.

### `TP2_LINUX_SSH_KEYS_JSON`

This maps Linux target `auth_ref` values to private SSH keys.

Example:

```json
{
  "linux1": "-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----",
  "linux2": "-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----"
}
```

If several Linux targets use the same SSH key, they can share the same `auth_ref`.

### `TP2_WINDOWS_PASSWORDS_JSON`

This maps Windows target `auth_ref` values to passwords.

Example:

```json
{
  "windows1": "change-me"
}
```

Secrets are not stored in the generated inventory artifact. The workflow rewrites Linux key files during each job and reads Windows passwords from the secret JSON at Ansible runtime.

## 7. Run Local Static Checks

From the repository root, validate Docker Compose:

```bash
docker compose -f TP2/docker-compose.yml config
```

Validate Terraform:

```bash
terraform -chdir=TP2/terraform fmt -check
terraform -chdir=TP2/terraform init
terraform -chdir=TP2/terraform validate
terraform -chdir=TP2/terraform plan -var-file=../targets.auto.tfvars.json
```

Build the Ansible controller:

```bash
docker compose -f TP2/docker-compose.yml build ansible-controller
```

Generate the inventory locally:

```bash
terraform -chdir=TP2/terraform apply -var-file=../targets.auto.tfvars.json -auto-approve
terraform -chdir=TP2/terraform output -json target_metadata > TP2/generated/targets.json

docker compose -f TP2/docker-compose.yml run --rm ansible-controller \
  python3 TP2/scripts/render_inventory.py \
  TP2/generated/targets.json \
  TP2/templates/inventory.yml.j2 \
  TP2/generated/inventory.yml

python3 TP2/scripts/write_traefik_env.py \
  TP2/targets.auto.tfvars.json \
  TP2/generated/traefik/traefik.env

docker compose -f TP2/docker-compose.yml run --rm ansible-controller \
  python3 TP2/scripts/render_inventory.py \
  TP2/generated/targets.json \
  TP2/templates/traefik-dynamic.yml.j2 \
  TP2/generated/traefik/dynamic.yml
```

Run an Ansible syntax check:

```bash
TP2_WINDOWS_PASSWORDS_JSON='{"windows1":"dummy"}' \
docker compose -f TP2/docker-compose.yml run --rm ansible-controller \
  ansible-playbook \
  -i TP2/generated/inventory.yml \
  TP2/ansible/playbooks/site.yml \
  --syntax-check
```

For a real local deployment, replace the dummy password JSON with the correct Windows password mapping and make sure Linux SSH key files exist under:

```text
TP2/generated/keys/AUTH_REF.pem
```

## 8. Run The GitHub Actions Pipeline

The workflow file is:

```text
.github/workflows/tp2-automation.yml
```

It runs on:

- pushes to `main`
- pull requests
- changes under `TP2/**`
- changes under `TP1/**`
- changes to the workflow itself

The pipeline jobs are:

1. `runner-proof`
   - checks out the repository
   - prints runner name, OS, architecture, hostname, workspace, and repository

2. `terraform-inventory`
   - writes target JSON from `TP2_TARGETS_JSON`
   - writes Linux SSH key files from `TP2_LINUX_SSH_KEYS_JSON`
   - runs Terraform format, init, validate, plan, and apply
   - exports `TP2/generated/targets.json`
   - renders `TP2/generated/inventory.yml` with Jinja2
   - renders `TP2/generated/traefik/dynamic.yml` with Jinja2
   - writes `TP2/generated/traefik/traefik.env` for Traefik ports
   - uploads the generated inventory artifact

3. `ansible-automation`
   - downloads the generated inventory artifact
   - restores Linux SSH keys from secrets
   - builds the Ansible controller
   - runs Ansible syntax check
   - gathers facts
   - changes and verifies Linux and Windows timezones
   - deploys TP1 with Docker Compose
   - starts Traefik on the runner host
   - validates direct target endpoints and Traefik-routed endpoints

## 9. What Ansible Deploys

For each enabled target, Ansible copies `TP1/` to the configured `deploy_path`.

These generated or heavy folders are excluded:

```text
.git
.env
frontend/node_modules
frontend/dist
frontend/playwright-report
frontend/test-results
backend/target
```

Ansible renders a fresh `.env` file from:

```text
TP2/ansible/templates/app.env.j2
```

When Traefik is enabled, the generated `.env` points the frontend build at the load-balanced backend hostname and allows the load-balanced frontend origin in backend CORS.

Then Ansible runs Docker Compose on the target:

```bash
docker compose up -d --build --remove-orphans
```

After every target is deployed, Ansible starts Traefik on the runner host with:

```bash
docker compose --env-file generated/traefik/traefik.env up -d traefik
```

## 10. Validate The Deployment

The pipeline validates these endpoints for every enabled target:

```text
GET  http://TARGET_HOST:5173
POST http://TARGET_HOST:8080/api/click
GET  http://TARGET_HOST:9090/-/ready
GET  http://TARGET_HOST:3000/api/health
```

It also validates these Traefik routes through the configured hostnames:

```text
GET  http://FRONTEND_HOSTNAME/
POST http://BACKEND_HOSTNAME/api/click
GET  http://PROMETHEUS_HOSTNAME/-/ready
GET  http://GRAFANA_HOSTNAME/api/health
```

The Traefik dashboard is available on:

```text
http://LOAD_BALANCER_HOST:8088/dashboard/
```

Grafana is available with the defaults rendered by `app.env.j2` unless you override them:

```text
username: admin
password: admin
```

## 11. Stop TP1 On The Targets

After inventory generation, stop TP1 with:

```bash
docker compose -f TP2/docker-compose.yml run --rm ansible-controller \
  ansible-playbook \
  -i TP2/generated/inventory.yml \
  TP2/ansible/playbooks/stop_tp1.yml
```

This stops Traefik on the runner host and stops TP1 on every enabled target.
