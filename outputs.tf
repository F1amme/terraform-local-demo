output "project_summary" {
  value = {
    name         = var.project_name
    id           = local.project_id
    environments = keys(var.environments)
    config_files = { for k, v in local_file.env_configs : k => v.filename }
    sensitive    = true
  }
  description = "Основная информация о проекте"
}

output "next_steps" {
  value = <<-EOT
  Project ${var.project_name} (${local.project_id}) configured successfully!
  
  Next steps:
  1. Review generated configs in ./configs/
  2. Check README.md for project documentation
  3. Run 'terraform output' to see generated secrets (marked as sensitive)
  
  Generated at: ${local.timestamp}
  EOT
}