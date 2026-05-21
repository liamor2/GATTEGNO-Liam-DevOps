variable "project_name" {
  type        = string
  description = "Project name used by this stack."
  default     = "click-tracker"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}
