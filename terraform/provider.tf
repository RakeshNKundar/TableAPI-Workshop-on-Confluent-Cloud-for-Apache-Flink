terraform {
  required_version = ">= 1.10.4"

  required_providers {

    confluent = {
      source  = "confluentinc/confluent"
      version = "2.36.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.CC_CLOUD_API_KEY    # optionally use CONFLUENT_CLOUD_API_KEY env var
  cloud_api_secret = var.CC_CLOUD_API_SECRET # optionally use CONFLUENT_CLOUD_API_SECRET env var

}