variable "project_name" {
  type = string
}

variable "environments" {
  type = list(string)
}

variable "alert_endpoints" {
  type = object({
    email = string
    slack = string
  })
  sensitive = true
}