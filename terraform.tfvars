variable "admin_username" {
  type        = string
  description = "Username to SSH into the VM"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Password to SSH into the VM"
}

