data "confluent_flink_region" "flink_region" {
  cloud  = var.CLOUD_PROVIDER
  region = var.REGION
}

resource "confluent_flink_compute_pool" "main" {
  display_name = "Flink_compute_pool_${random_string.resource_suffix.id}"
  cloud        = var.CLOUD_PROVIDER
  region       = var.REGION
  max_cfu      = 50
  environment {
    id = confluent_environment.cc_flink_tableapi_workshop.id
  }
}
