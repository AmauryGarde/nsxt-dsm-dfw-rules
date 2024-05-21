variable "nsx_manager_hostname" {
  description = "Hostname of the NSX manager"
}

variable "nsx_manager_username" {
  description = "Username for the NSX manager"
}

variable "nsx_manager_password" {
  description = "Password for the NSX manager"
}

variable "provider_vm_ip" {
  description = "IP address of the Provider VM"
}

variable "air_gapped_deployment" {
  description = "Flag to indicate if this is an air-gapped deployment"
  type        = bool
  default     = false
}

variable "database_segment_ranges" {
  description = "List of IP ranges for the database segment"
  type        = list(string)
}

variable "app_segment_ranges" {
  description = "List of IP ranges for the app segment"
  type        = list(string)
}

variable "s3_ips" {
  description = "List of S3-compatible storage IPs"
  type        = list(string)
}

variable "end_user_ranges" {
  description = "List of End User IP ranges"
  type        = list(string)
}

variable "database_client_ranges" {
  description = "List of Database Client IP ranges"
  type        = list(string)
}
