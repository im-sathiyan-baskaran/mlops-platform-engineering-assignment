variable "region" {
  type    = string
  default = "us-east-1"
}

variable "github_repo" {
  description = "owner/repo allowed to publish charts"
  type        = string
  default     = "im-sathiyan-baskaran/mlops-platform-engineering-assignment"
}

variable "chart_name" {
  type    = string
  default = "ml-api"
}

variable "keep_last_versions" {
  type    = number
  default = 20
}