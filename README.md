# Java Table API Hands on with Confluent Cloud for Apache Flink

This github repo walks you through the complete setup of running Flink jobs on fully managed Confluent Cloud for Apache Flink using Table API in Java programming language step-by-step from scratch. This repo is focused for people who wants to get started with Flink TableAPI and Confluent's Flink offering. 



## Prerequisites
- Confluent Cloud account(https://confluent.cloud)
- Terraform
- Maven

## High Level Overview

This repo does the following steps 

- In terraform script does the following things
- Creates a Confluent Cloud environment and a Kafka cluster on GCP cloud
- Spins up a fully managed Confluent Flink compute pool for the Flink jobs to run


## Setup
Clone this github repository to your working directory. Set the working path to simplify the command executions.
```
git clone https://github.com/RakeshNKundar/churn-prediction-with-cc-flink-ai.git ####### 

cd cc-flink-table-api-workshop

export TUTORIAL_PATH=$(pwd)
```

## Step : Generate Confluent Cloud API Key.
This repo uses Confluent's terraform provider to automate the infrastructure setup. Confluent terraform provider requires a special type of API key named **CLOUD_API_KEY** to interact with Confluent for the infrastructure management. Follow the below instructions to generate one.

- Login to your Confluent Cloud account(https://confluent.cloud)

![CC Home Page](./assets/images/cc_home_page.png)

- Click on the Hamberger icon on the top right of the sreen and select API keys menu

![Choose API key menu from the Hamberger icon](./assets/images/hamburger_icon_api_key.png)

- Click on **ADD API Key** button 

![Add API Key button](./assets/images/add_api_key_button.png)

- Select My Account option. **Note:** The user needs to have Organization Admin Role to create this API Key.

![Select My Account option](./assets/images/account_selection_api_key.png)

- Choose Cloud Resource management option

![Choose Cloud Resource management option](./assets/images/cloud_resource_management_api_key.png)

- Fill in Name and Description to your API key and then click on **Create** button. API Secret will be visible only once so you can download to your machine for later usage.

![Fill name and secret to the API Key](./assets/images/name_and_description_api_key.png)


## Step : Configuring terraform and spinning up CC infrastructure

Once the Confluent Cloud API key is generated, Navigate to the terraform directory and run the below commands to run the terraform scripts. Paste the **CC_CLOUD_API_KEY** and **CC_CLOUD_API_SECRET** values when prompted.

```
# Initialize the terraform directory
terraform init

# Apply the terraform scripts
terraform apply --auto-approve
```

Once the terraform completes its execution, following resources are created automatically.
- Confluent Environment named **CC_Flink_TableAPI_Workshop**
- Confluent Kafka Cluster named **Table_API_Workshop_Kafka_Cluster**
- Flink Compute Pool named **Flink_compute_pool**

## Step : Running the Table API Flink Job 
In the current working directory, You'll see a folder **flink-table-api-example** with a maven Java TableAPI code with simple Flink transformations. With TableAPI you can write your Flink Jobs either with Java or Python programming languages. This gives more flexibility for teams comfortable with high level languages. So the Java project would require 2 important dependencies in the pom.xml file:
- **flink-table-api-java** : Open source Flink's Table API package for defining the Flink Jobs
- **confluent-flink-table-api-java-plugin** : Confluent's Table API java plugin used to interact with Flink compute pool created on Confluent Cloud using REST endpoints.

The Flink Table API code in the **flink-table-api-example** directory has Flink Job which uses sample marketplace mock provided by CC Flink compute pool to perform the following transformations. We will be using `ORDERS` and `PRODUCTS` sample data to:

- Filter `ORDERS` events from a specific range of customer_ids and stored it into `orders_filtered` table backed by a kafka topic.
- Calculate the total sale of each product within every interval of `1 MINUTE` using `TUMBLE` window and `GROUP BY` operations on the `ORDERS` events and is stored it into `orders_windowed_aggregation` backed by a kafka topic.
- Perform real-time join of `ORDERS` and `PRODUCTS` events to get an enriched table `orders_product_enriched` table for any downstream consumers to process.

To run the Flink job, Navigate to `flink-table-api-example` directory and run the following commands.

```
# To create a JAR file
mvn clean package

# To run the JAR code
java -jar flink-table-api-java-examples-1.0.jar

```

The above commands will submit the Flink Job to the CC Flink compute pool and you can observe the statements on the compute pool.

## Teardown Resources
Once you have completed the setup you can delete all the resources in one go through terraform.

Navigate to `terraform` directory and run `terraform destroy` command.
