variable "CC_CLOUD_API_KEY" {
  type        = string
  description = "Cloud API Key of Confluent Cloud"
}

variable "CC_CLOUD_API_SECRET" {
  type        = string
  description = "Cloud API Key of Confluent Cloud"
}

variable "CLOUD_PROVIDER" {
  type        = string
  description = "Cloud Provider Name"
  default     = "GCP"
}

variable "REGION" {
  type        = string
  description = "Region within confluent cloud aws csp"
  default     = "us-east1"
}

