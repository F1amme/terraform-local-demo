terraform {
  required_version = ">= 1.5.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

locals {
  timestamp = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  project_id = "prj-${random_id.project_id.hex}"
  
  common_tags = merge({
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "local"
    Created     = local.timestamp
  }, jsondecode(fileexists("tags.json") ? file("tags.json") : "{}"))
  
  normalized_envs = { for k, v in var.environments : 
    k => merge(v, {
      name       = upper(k)
      config_path = "configs/${k}.json"
    })
  }
}

resource "random_password" "secrets" {
  for_each = local.normalized_envs
  
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  
  keepers = {
    env_name = each.key
  }
}

resource "random_id" "project_id" {
  byte_length = 8
}

resource "local_file" "env_configs" {
  for_each = local.normalized_envs
  
  filename = each.value.config_path
  content = jsonencode({
    environment = each.key
    debug       = each.value.debug
    log_level   = each.value.log_level
    features    = each.value.feature_flags
    secrets     = {
      db_password = random_password.secrets[each.key].result
      api_key     = sha256("${local.project_id}-${each.key}")
    }
  })
  
  directory_permission = "0755"
  file_permission     = "0644"
}

resource "local_file" "readme" {
  filename = "README.md"
  content = templatefile("${path.module}/templates/README.md.tftpl", {
    project_name = var.project_name
    project_id   = local.project_id
    environments = keys(var.environments)
    generated_at = local.timestamp
    has_prod     = contains(keys(var.environments), "prod")
  })
}

resource "null_resource" "post_setup" {
  depends_on = [local_file.env_configs]

  triggers = {
    config_hash = md5(join("", [for f in local_file.env_configs : f.content]))
    timestamp   = timestamp()
  }

  provisioner "local-exec" {
     command = "echo 'Post-configuration setup'"
  }
  
  provisioner "local-exec" {
     command     = "mkdir -p logs && echo '${replace(jsonencode(local.normalized_envs), "\r", "")}' > logs/environments.json"
     interpreter = ["/bin/sh", "-c"]
  }
}

module "monitoring" {
  count = var.environments["prod"] != null ? 1 : 0
  
  source = "./modules/monitoring"
  
  project_name    = var.project_name
  environments    = keys(var.environments)
  alert_endpoints = var.alert_endpoints
}