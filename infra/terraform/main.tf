terraform {
  required_version = ">= 1.6.0"
}

locals {
  compose_project_name = "${var.project_name}-${var.environment}"
  deploy_mode_local    = var.deploy_mode == "self_hosted_local"
}

resource "terraform_data" "vm_docker_compose_deploy" {
  count = var.deploy_enabled ? 1 : 0

  triggers_replace = [
    var.deploy_version,
    var.deploy_mode,
    var.vm_host,
    var.vm_user,
    var.vm_ssh_port,
    var.vm_app_dir,
    filesha256("${path.module}/../../docker-compose.yml"),
    filesha256("${path.module}/../../backend/Dockerfile"),
    filesha256("${path.module}/../../frontend/Dockerfile")
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail

      if [ ! -f "${var.ssh_private_key_path}" ]; then
        if [ "${var.deploy_mode}" = "ssh_remote" ]; then
          echo "Missing SSH private key at ${var.ssh_private_key_path}" >&2
          exit 1
        fi
      fi

      if [ "${var.deploy_mode}" != "self_hosted_local" ] && [ "${var.deploy_mode}" != "ssh_remote" ]; then
        echo "Unsupported deploy_mode: ${var.deploy_mode}" >&2
        exit 1
      fi

      if [ "${var.deploy_mode}" = "self_hosted_local" ]; then
        cd "${var.repo_root}"

        cat <<'ENV_EOF' > .env
${var.app_env_content}
ENV_EOF

        docker compose -p ${local.compose_project_name} up -d --build --remove-orphans
        exit 0
      fi

      SSH_OPTS="-i ${var.ssh_private_key_path} -p ${var.vm_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

      ssh $SSH_OPTS ${var.vm_user}@${var.vm_host} "mkdir -p ${var.vm_app_dir}"

      rsync -az --delete \
        --exclude '.git' \
        --exclude '.github' \
        --exclude 'frontend/node_modules' \
        --exclude 'frontend/dist' \
        --exclude 'frontend/playwright-report' \
        --exclude 'frontend/test-results' \
        --exclude 'backend/target' \
        -e "ssh $SSH_OPTS" \
        ${var.repo_root}/ ${var.vm_user}@${var.vm_host}:${var.vm_app_dir}/

      cat <<'ENV_EOF' > /tmp/click-tracker.env
${var.app_env_content}
ENV_EOF

      scp $SSH_OPTS /tmp/click-tracker.env ${var.vm_user}@${var.vm_host}:${var.vm_app_dir}/.env

      ssh $SSH_OPTS ${var.vm_user}@${var.vm_host} "cd ${var.vm_app_dir} && docker compose -p ${local.compose_project_name} up -d --build --remove-orphans"

      rm -f /tmp/click-tracker.env
    EOT
  }
}

output "deployment_target" {
  value = {
    enabled = var.deploy_enabled
    mode    = var.deploy_mode
    host    = var.vm_host
    app_dir = var.vm_app_dir
  }
}
