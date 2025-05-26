variable "admin_username" {
  type        = string
  description = "The admin username for the VM"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "The admin password for the VM"
}

variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}
