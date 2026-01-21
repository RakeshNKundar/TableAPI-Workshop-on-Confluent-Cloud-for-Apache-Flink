output "organization_id" {
  description = "Organization ID of the Confluent account"
  value       = data.confluent_organization.cc_organization.id
}

output "environment_id" {
  description = "Confluent Cloud environment ID"
  value       = confluent_environment.cc_flink_tableapi_workshop.id
}

output "cluster_id" {
  description = "Confluent Cloud Kafka Cluster ID"
  value       = confluent_kafka_cluster.flink_tableapi_demo_cluster.id
}

output "compute_pool_id" {
  description = "Confluent Cloud Flink Compute ID"
  value       = confluent_flink_compute_pool.main.id
}

output "flink_api_key" {
  description = "Confluent Cloud Flink API Key"
  value       = confluent_api_key.flink_api_key.id
}

output "flink_api_secret" {
  description = "Confluent Cloud Flink API Secret"
  value       = confluent_api_key.flink_api_key.secret
  sensitive   = true
}

output "environment_name" {
  description = "Confluent Cloud Environment Name"
  value       = confluent_environment.cc_flink_tableapi_workshop.display_name
}

output "kafka_cluster_name" {
  description = "Confluent Cloud Kafka Cluster Name"
  value       = confluent_kafka_cluster.flink_tableapi_demo_cluster.display_name
}