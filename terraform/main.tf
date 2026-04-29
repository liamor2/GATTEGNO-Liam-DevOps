terraform {
  required_version = ">= 1.4.0"
}

resource "terraform_data" "proof_of_execution" {
  input = {
    executed_at = timestamp()
  }

  triggers_replace = timestamp()

  provisioner "local-exec" {
    command = "printf '%s\n' 'Executed at ${self.input.executed_at}. Created with Terraform.' > ../proof_of_execution"
  }
}
