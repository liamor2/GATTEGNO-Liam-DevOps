variable "linux_host" {
  type        = string
  description = "Linux target VM address."
}

variable "linux_user" {
  type        = string
  description = "SSH user for the Linux target VM."
  default     = "ubuntu"
}

variable "linux_ssh_port" {
  type        = number
  description = "SSH port for the Linux target VM."
  default     = 22
}

variable "linux_ssh_private_key_file" {
  type        = string
  description = "Path to the Linux SSH private key file inside the pipeline workspace."
  default     = "/workspace/TP2/generated/linux_id_rsa"
}

variable "linux_deploy_path" {
  type        = string
  description = "Directory where TP1 is deployed on the Linux VM."
  default     = "/opt/clicktracker/TP1"
}

variable "windows_host" {
  type        = string
  description = "Windows target VM address."
}

variable "windows_user" {
  type        = string
  description = "WinRM user for the Windows target VM."
  default     = "Administrator"
}

variable "windows_winrm_port" {
  type        = number
  description = "WinRM HTTPS port for the Windows target VM."
  default     = 5986
}

variable "windows_deploy_path" {
  type        = string
  description = "Directory where TP1 is deployed on the Windows VM."
  default     = "C:\\clicktracker\\TP1"
}

variable "timezone_first" {
  type        = string
  description = "First timezone applied and verified by Ansible."
  default     = "Europe/Paris"
}

variable "timezone_second" {
  type        = string
  description = "Second timezone applied and verified by Ansible."
  default     = "Africa/Abidjan"
}

variable "cloud_ready_providers" {
  type        = list(string)
  description = "Cloud provider integration targets documented for architecture alignment."
  default     = ["aws", "gcp", "azure", "alibaba"]
}
