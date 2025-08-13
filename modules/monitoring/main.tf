resource "local_file" "monitoring_config" {
  filename = "monitoring/alerts.json"
  content = jsonencode({
    project     = var.project_name
    environments = var.environments
    alerts      = {
      email = var.alert_endpoints.email
      slack = var.alert_endpoints.slack
    }
  })
}