data "confluent_organization" "cc_organization" {}

resource "confluent_environment" "cc_flink_tableapi_workshop" {
  display_name = "TableAPI_Workshop_${random_string.resource_suffix.id}"

  stream_governance {
    package = "ESSENTIALS"
  }
}


resource "confluent_kafka_cluster" "flink_tableapi_demo_cluster" {
  display_name = "Kafka_Cluster_${random_string.resource_suffix.id}"
  availability = "SINGLE_ZONE"
  cloud        = var.CLOUD_PROVIDER
  region       = var.REGION

  basic {}

  environment {
    id = confluent_environment.cc_flink_tableapi_workshop.id
  }
}

data "confluent_schema_registry_cluster" "cc_flink_tableapi_workshop_sr" {
  environment {
    id = confluent_environment.cc_flink_tableapi_workshop.id
  }

  depends_on = [ confluent_kafka_cluster.flink_tableapi_demo_cluster]
}

resource "confluent_service_account" "flink_tableapi_sa" {
  display_name = "flink_tableapi_SA_${random_string.resource_suffix.id}"
  description  = "Service Account for CC Flink TableAPI Workshop"
}

resource "confluent_role_binding" "flink_tableapi_sa_cluster_admin_rb" {
  principal   = "User:${confluent_service_account.flink_tableapi_sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.flink_tableapi_demo_cluster.rbac_crn

  depends_on = [confluent_service_account.flink_tableapi_sa]
}


resource "confluent_api_key" "flink_tableapi_workshop_kafka_api_key" {
  display_name = "CC_Flink_TableAPI_Workshop_API_Key_${random_string.resource_suffix.id}"
  description  = "API Key for Table API Workshop Kafka Cluste with CloudClusterAdmin RBAC"
  owner {
    id          = confluent_service_account.flink_tableapi_sa.id
    api_version = confluent_service_account.flink_tableapi_sa.api_version
    kind        = confluent_service_account.flink_tableapi_sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.flink_tableapi_demo_cluster.id
    api_version = confluent_kafka_cluster.flink_tableapi_demo_cluster.api_version
    kind        = confluent_kafka_cluster.flink_tableapi_demo_cluster.kind

    environment {
      id = confluent_environment.cc_flink_tableapi_workshop.id
    }
  }

  depends_on = [confluent_service_account.flink_tableapi_sa, confluent_role_binding.flink_tableapi_sa_cluster_admin_rb]
}

resource "confluent_service_account" "flink_sa" {
  display_name = "Flink_SA_${random_string.resource_suffix.id}"
  description  = "Service account for Flink Compute pool access"
}

resource "confluent_role_binding" "flink_admin" {
  principal   = "User:${confluent_service_account.flink_sa.id}"
  role_name   = "FlinkAdmin"
  crn_pattern = confluent_environment.cc_flink_tableapi_workshop.resource_name
}

resource "confluent_role_binding" "flink_cloud_cluster_admin" {
  principal   = "User:${confluent_service_account.flink_sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.flink_tableapi_demo_cluster.rbac_crn
}

resource "confluent_role_binding" "schema_registry_all_subjects" {
  principal   = "User:${confluent_service_account.flink_sa.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${data.confluent_schema_registry_cluster.cc_flink_tableapi_workshop_sr.resource_name}/subject=*"
}


resource "confluent_api_key" "flink_api_key" {
  display_name = "flink-api-key_${random_string.resource_suffix.id}"

  owner {
    id          = confluent_service_account.flink_sa.id
    api_version = confluent_service_account.flink_sa.api_version
    kind        = confluent_service_account.flink_sa.kind
  }

  managed_resource {
    id          = data.confluent_flink_region.flink_region.id
    api_version = data.confluent_flink_region.flink_region.api_version
    kind        = data.confluent_flink_region.flink_region.kind
    environment {
      id = confluent_environment.cc_flink_tableapi_workshop.id
    }
  }
}