output "monitoring_config_path" {
  value       = local_file.monitoring_config.filename
  description = "Path to generated monitoring configuration file"
}

output "sensitive_alert_endpoints" {
  value       = var.alert_endpoints
  description = "Alert endpoints configuration (marked as sensitive)"
  sensitive   = true
}

output "monitoring_summary" {
  value = {
    config_file  = local_file.monitoring_config.filename
    environments = length(var.environments)
    has_email    = var.alert_endpoints.email != ""
    has_slack    = var.alert_endpoints.slack != ""
  }
  description = "Summary of monitoring module configuration"
}