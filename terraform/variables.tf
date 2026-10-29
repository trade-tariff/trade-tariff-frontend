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

variable "cpu" {
  description = "CPU units to use."
  type        = number
}

variable "memory" {
  description = "Memory to allocate in MB. Powers of 2 only."
  type        = number
}

variable "enable_alarms" {
  description = "Whether to enable CloudWatch alarms for the service. Defaults to `true`."
  type        = bool
  default     = true
}

variable "enable_observability_alerts" {
  type    = bool
  default = false
}

variable "scale_in_cooldown" {
  description = "Prevents aggressive scale-in by enforcing a waiting period after tasks are removed."
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Minimum time to wait after a scale-out before allowing another scale-out, giving new tasks time to start contributing capacity."
  type        = number
  default     = 60
}

variable "generated_secrets" {
  description = "UAT only. Environment variables mapped to the Secrets Manager secret that has the value. The common stack creates these secrets on each start. They replace the values in the configuration secret."
  type        = map(string)
  default     = {}
}

variable "generated_parameters" {
  description = "UAT only. Environment variables mapped to the SSM parameter that has the value. The common stack creates these parameters on each start. They replace the values in the configuration secret."
  type        = map(string)
  default     = {}
}
