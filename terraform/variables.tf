variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "region" {
  description = "AWS region to use."
  type        = string
}

variable "docker_tag" {
  description = "Image tag to use."
  type        = string
}

variable "service_count" {
  description = "Number of services to use."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Smallest number of tasks the service can scale-in to."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Largest number of tasks the service can scale-out to."
  type        = number
  default     = 5
}

variable "base_domain" {
  description = "URL of the service."
  type        = string
}

variable "cpu" {
  description = "CPU units to use."
  type        = number
}

variable "memory" {
  description = "Memory to allocate in MB. Powers of 2 only."
  type        = number
}

variable "tariff_email_to" {
  description = "Email address to send emails to."
  type        = string
}

variable "green_lanes_enabled" {
  description = "Enable green lanes api UI in front end"
  type        = bool
  default     = false
}

variable "google_tag_manager_container_id" {
  description = "Google Tag Manager container ID"
  type        = string
}
