terraform {
  required_version = ">= 1.6.0"
}

resource "terraform_data" "project_metadata" {
  input = {
    project_name = var.project_name
    environment  = var.environment
  }
}

output "project_metadata" {
  value = terraform_data.project_metadata.output
}
