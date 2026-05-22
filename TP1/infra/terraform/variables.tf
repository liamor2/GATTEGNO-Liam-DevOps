variable "project_name" {
  type        = string
  description = "Project name used by this stack."
  default     = "click-tracker"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "prod"
}

variable "deploy_enabled" {
  type        = bool
  description = "When true, Terraform executes VM deployment commands."
  default     = false
}

variable "deploy_mode" {
  type        = string
  description = "Deployment mode: self_hosted_local or ssh_remote."
  default     = "self_hosted_local"
}

variable "deploy_version" {
  type        = string
  description = "Unique deployment identifier, typically commit SHA."
  default     = "manual"
}

variable "repo_root" {
  type        = string
  description = "Local path to repository root on the machine running Terraform."
  default     = "../.."
}

variable "vm_host" {
  type        = string
  description = "Target VM public host or IP."
  default     = ""
}

variable "vm_user" {
  type        = string
  description = "SSH username for the target VM."
  default     = ""
}

variable "vm_ssh_port" {
  type        = number
  description = "SSH port for target VM."
  default     = 22
}

variable "vm_app_dir" {
  type        = string
  description = "Deployment directory on VM."
  default     = "/opt/click-tracker"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key on the Terraform runner."
  default     = "/tmp/deploy_key"
}

variable "app_env_content" {
  type        = string
  description = "Content of runtime .env file written on VM."
  sensitive   = true
  default     = "POSTGRES_DB=clickdb\nPOSTGRES_USER=clickuser\nPOSTGRES_PASSWORD=clickpass\nAPP_CORS_ALLOWED_ORIGIN_PATTERNS=http://localhost:*,http://127.0.0.1:*\nVITE_API_BASE_URL=http://localhost:8080"
}
