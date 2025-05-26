variable "admin_username" {
  type        = string
  description = "The admin username for the VM"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "The admin password for the VM"
}
