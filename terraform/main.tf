terraform {
  required_version = ">= 1.4.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

locals {
  executed_at = timestamp()
}

resource "local_file" "proof_of_execution" {
  filename = "${path.module}/../proof_of_execution"
  content = templatefile("${path.module}/templates/proof_of_execution.tftpl", {
    executed_at = local.executed_at
  })
}
