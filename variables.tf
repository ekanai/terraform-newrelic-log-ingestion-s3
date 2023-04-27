variable "bucket_arn" {
  type        = string
  description = "Bucket ARN"
}

variable "kms_arn" {
  type        = string
  description = "KMS ARN"
}

variable "application_version" {
  type        = string
  description = "Application Version"
  default     = ""
}

variable "license_key" {
  type        = string
  description = "License Key"
}

variable "log_type" {
  # https://docs.newrelic.com/jp/docs/logs/ui-data/built-log-parsing-rules/
  type        = string
  description = "Log Type"
  default     = ""
}
