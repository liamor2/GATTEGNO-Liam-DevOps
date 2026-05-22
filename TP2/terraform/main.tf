locals {
  linux_ports = {
    frontend   = 5173
    backend    = 8080
    prometheus = 9090
    grafana    = 3000
  }

  windows_ports = {
    frontend   = 5173
    backend    = 8080
    prometheus = 9090
    grafana    = 3000
  }

  target_metadata = {
    controller = {
      name       = "ansible-controller"
      connection = "local"
      runtime    = "docker"
    }
    linux = {
      name                 = "linux-target"
      host                 = var.linux_host
      user                 = var.linux_user
      ssh_port             = var.linux_ssh_port
      ssh_private_key_file = var.linux_ssh_private_key_file
      deploy_path          = var.linux_deploy_path
      ports                = local.linux_ports
    }
    windows = {
      name        = "windows-target"
      host        = var.windows_host
      user        = var.windows_user
      winrm_port  = var.windows_winrm_port
      deploy_path = var.windows_deploy_path
      ports       = local.windows_ports
    }
    automation = {
      timezone_first        = var.timezone_first
      timezone_second       = var.timezone_second
      cloud_ready_providers = var.cloud_ready_providers
    }
  }
}

output "target_metadata" {
  description = "Target metadata consumed by the Jinja2 inventory rendering step."
  value       = local.target_metadata
}
