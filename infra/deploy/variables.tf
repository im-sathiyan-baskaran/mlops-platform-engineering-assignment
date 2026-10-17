variable "environment" {
  description = "dev, staging or production (also used as the namespace)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be dev, staging or production."
  }
}

variable "service" {
  type    = string
  default = "iris-api"
}

variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "kind-mlapi"
}

variable "chart_repository" {
  description = "OCI repository of the published chart. null = deploy the chart from this checkout."
  type        = string
  default     = null
}

variable "chart_version" {
  type    = string
  default = null
}

variable "existing_secret" {
  description = "Name (never the value) of a Secret that already exists in the namespace"
  type        = string
  default     = ""
}
