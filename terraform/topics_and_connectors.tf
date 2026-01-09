# resource "confluent_kafka_topic" "orders" {
#   kafka_cluster {
#     id = confluent_kafka_cluster.flink_tableapi_demo_cluster.id
#   }
#   topic_name       = "orders"
#   rest_endpoint    = confluent_kafka_cluster.flink_tableapi_demo_cluster.rest_endpoint
#   partitions_count = 3

#   credentials {
#     key    = confluent_api_key.flink_tableapi_workshop_kafka_api_key.id
#     secret = confluent_api_key.flink_tableapi_workshop_kafka_api_key.secret
#   }

#   depends_on = [confluent_kafka_cluster.flink_tableapi_demo_cluster, confluent_api_key.flink_tableapi_workshop_kafka_api_key]
# }

# resource "confluent_kafka_topic" "products" {
#   kafka_cluster {
#     id = confluent_kafka_cluster.flink_tableapi_demo_cluster.id
#   }
#   topic_name       = "products"
#   rest_endpoint    = confluent_kafka_cluster.flink_tableapi_demo_cluster.rest_endpoint
#   partitions_count = 3

#   credentials {
#     key    = confluent_api_key.flink_tableapi_workshop_kafka_api_key.id
#     secret = confluent_api_key.flink_tableapi_workshop_kafka_api_key.secret
#   }

#   depends_on = [confluent_kafka_cluster.flink_tableapi_demo_cluster, confluent_api_key.flink_tableapi_workshop_kafka_api_key]
# }


# resource "confluent_connector" "datagen_connector_orders" {
#   environment {
#     id = confluent_environment.cc_flink_tableapi_workshop.id
#   }
#   kafka_cluster {
#     id = confluent_kafka_cluster.flink_tableapi_demo_cluster.id
#   }

#   config_sensitive = {}

#   config_nonsensitive = {
#     "connector.class"          = "DatagenSource"
#     "name"                     = "DatagenSourceConnector_Orders"
#     "kafka.auth.mode"          = "SERVICE_ACCOUNT"
#     "kafka.service.account.id" = confluent_service_account.flink_tableapi_sa.id
#     "kafka.topic"              = confluent_kafka_topic.orders.topic_name
#     "output.data.format"       = "AVRO"
#     "quickstart"               = "ORDERS"
#     "tasks.max"                = "1"
#   }

#   depends_on = [
#     confluent_kafka_cluster.flink_tableapi_demo_cluster,
#     confluent_kafka_topic.orders,
#     confluent_service_account.flink_tableapi_sa,
#     confluent_api_key.flink_tableapi_workshop_kafka_api_key
#   ]
# }


# resource "confluent_connector" "datagen_connector_products" {
#   environment {
#     id = confluent_environment.cc_flink_tableapi_workshop.id
#   }
#   kafka_cluster {
#     id = confluent_kafka_cluster.flink_tableapi_demo_cluster.id
#   }

#   config_sensitive = {}

#   config_nonsensitive = {
#     "connector.class"          = "DatagenSource"
#     "name"                     = "DatagenSourceConnector_Products"
#     "kafka.auth.mode"          = "SERVICE_ACCOUNT"
#     "kafka.service.account.id" = confluent_service_account.flink_tableapi_sa.id
#     "kafka.topic"              = confluent_kafka_topic.products.topic_name
#     "output.data.format"       = "AVRO"
#     "schema.filename"          = "./schema/products.avsc"
#     "tasks.max"                = "1"
#     "schema.string"            = <<EOF
#                         {
#                         "namespace": "ksql",
#                         "name": "product",
#                         "type": "record",
#                         "fields": [
#                                 {"name": "id", 
#                                 "type":{
#                                     "type":"string",
#                                     "arg.properties":{
#                                     "regex":"Item_[1-9][0-9]{0,2}"
#                                     }
#                                 }},
#                                 {"name": "name", 
#                                 "type":{
#                                     "type":"string",
#                                     "arg.properties":{
#                                     "regex":"Product_[1-9][0-9]{0,2}"
#                                     }
#                                 }},
#                                 {"name": "price", 
#                                 "type": {
#                                     "type": "double",
#                                     "arg.properties": {
#                                       "iteration": {
#                                           "start": 10
#                                           }
#                                       }
#                                 }}
#         ]
# }
# EOF
#   }

#   depends_on = [
#     confluent_kafka_cluster.flink_tableapi_demo_cluster,
#     confluent_kafka_topic.products,
#     confluent_service_account.flink_tableapi_sa,
#     confluent_api_key.flink_tableapi_workshop_kafka_api_key
#   ]
# }