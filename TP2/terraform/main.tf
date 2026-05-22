locals {
  default_ports = {
    frontend   = 5173
    backend    = 8080
    prometheus = 9090
    grafana    = 3000
  }

  enabled_targets = {
    for name, target in var.targets : name => target
    if target.enabled
  }

  linux_targets = {
    for name, target in local.enabled_targets : name => {
      name                 = name
      host                 = target.host
      user                 = target.user
      ssh_port             = coalesce(target.port, 22)
      auth_ref             = coalesce(target.auth_ref, name)
      ssh_private_key_file = "/workspace/TP2/generated/keys/${coalesce(target.auth_ref, name)}.pem"
      deploy_path          = coalesce(target.deploy_path, "/opt/clicktracker/TP1")
      ports                = merge(local.default_ports, target.ports)
    }
    if lower(target.os) == "linux"
  }

  windows_targets = {
    for name, target in local.enabled_targets : name => {
      name        = name
      host        = target.host
      user        = target.user
      winrm_port  = coalesce(target.port, 5986)
      auth_ref    = coalesce(target.auth_ref, name)
      deploy_path = coalesce(target.deploy_path, "C:\\clicktracker\\TP1")
      ports       = merge(local.default_ports, target.ports)
    }
    if lower(target.os) == "windows"
  }

  required_target_os_is_present = (
    !var.enforce_required_target_os ||
    (length(local.linux_targets) > 0 && length(local.windows_targets) > 0)
  )

  target_metadata = {
    controller = {
      name       = "ansible-controller"
      connection = "local"
      runtime    = "docker"
    }
    linux_targets   = local.linux_targets
    windows_targets = local.windows_targets
    automation = {
      timezone_first          = var.timezone_first
      timezone_second         = var.timezone_second
      windows_timezone_first  = var.windows_timezone_first
      windows_timezone_second = var.windows_timezone_second
      cloud_ready_providers   = var.cloud_ready_providers
    }
  }
}

resource "terraform_data" "required_target_os_guard" {
  input = local.required_target_os_is_present

  lifecycle {
    precondition {
      condition     = local.required_target_os_is_present
      error_message = "TP2 requires at least one enabled linux target and one enabled windows target. Set enforce_required_target_os=false only for local experiments."
    }
  }
}

output "target_metadata" {
  description = "Target metadata consumed by the Jinja2 inventory rendering step."
  value       = local.target_metadata
}
