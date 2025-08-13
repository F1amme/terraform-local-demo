variable "project_name" {
  description = "Название проекта (должно содержать только буквы и цифры)"
  type        = string
  default     = "terraform-local-demo"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name can only contain alphanumeric characters and hyphens."
  }
}

variable "environments" {
  description = "Список окружений с настройками"
  type = map(object({
    debug        = bool
    log_level    = string
    feature_flags = list(string)
  }))
  default = {
    dev = {
      debug        = true
      log_level    = "DEBUG"
      feature_flags = ["new_ui", "experimental_api"]
    },
    stage = {
      debug        = true
      log_level    = "INFO"
      feature_flags = ["new_ui"]
    },
    prod = {
      debug        = false
      log_level    = "WARN"
      feature_flags = []
    }
  }
}

variable "alert_endpoints" {
  description = "Конечные точки для оповещений"
  type = object({
    email = string
    slack = string
  })
  default = {
    email = "team@example.com"
    slack = "https://hooks.slack.com/services/..."
  }
  sensitive = true
}