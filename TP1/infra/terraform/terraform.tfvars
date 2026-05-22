project_name = "click-tracker"
environment  = "prod"

deploy_enabled = false
deploy_version = "manual"

vm_host     = "127.0.0.1"
vm_user     = "ubuntu"
vm_ssh_port = 22
vm_app_dir  = "/opt/click-tracker"

ssh_private_key_path = "/tmp/deploy_key"

app_env_content = <<-EOT
POSTGRES_DB=clickdb
POSTGRES_USER=clickuser
POSTGRES_PASSWORD=clickpass
APP_CORS_ALLOWED_ORIGIN_PATTERNS=http://localhost:*,http://127.0.0.1:*
VITE_API_BASE_URL=http://localhost:8080
EOT
