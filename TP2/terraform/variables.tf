variable "targets" {
  type = map(object({
    enabled     = optional(bool, true)
    os          = string
    host        = string
    user        = string
    port        = optional(number)
    auth_ref    = optional(string)
    deploy_path = optional(string)
    ports = optional(object({
      frontend   = optional(number, 5173)
      backend    = optional(number, 8080)
      prometheus = optional(number, 9090)
      grafana    = optional(number, 3000)
    }), {})
  }))
  description = "Managed VM targets. Add, remove, or disable entries to change deployment targets."

  validation {
    condition = alltrue([
      for target in values(var.targets) : contains(["linux", "windows"], lower(target.os))
    ])
    error_message = "Each target os must be either linux or windows."
  }

  validation {
    condition = alltrue([
      for name, target in var.targets : can(regex("^[A-Za-z0-9_-]+$", name))
    ])
    error_message = "Target names may contain only letters, numbers, underscores, and hyphens."
  }
}

variable "enforce_required_target_os" {
  type        = bool
  description = "Require at least one enabled Linux target and one enabled Windows target for grading."
  default     = true
}

variable "load_balancer" {
  type = object({
    enabled        = optional(bool, true)
    host           = optional(string, "localhost")
    http_port      = optional(number, 80)
    dashboard_port = optional(number, 8088)
    hostnames = optional(object({
      frontend   = optional(string, "app.localhost")
      backend    = optional(string, "api.localhost")
      prometheus = optional(string, "prometheus.localhost")
      grafana    = optional(string, "grafana.localhost")
    }), {})
  })
  description = "Traefik load balancer settings running on the TP2 runner host."
  default     = {}
}

variable "timezone_first" {
  type        = string
  description = "First Linux timezone applied and verified by Ansible."
  default     = "Europe/Paris"
}

variable "timezone_second" {
  type        = string
  description = "Second Linux timezone applied and verified by Ansible."
  default     = "Africa/Abidjan"
}

variable "windows_timezone_first" {
  type        = string
  description = "First Windows timezone ID applied and verified by Ansible."
  default     = "Romance Standard Time"
}

variable "windows_timezone_second" {
  type        = string
  description = "Second Windows timezone ID applied and verified by Ansible."
  default     = "Greenwich Standard Time"
}

variable "cloud_ready_providers" {
  type        = list(string)
  description = "Cloud provider integration targets documented for architecture alignment."
  default     = ["aws", "gcp", "azure", "alibaba"]
}
