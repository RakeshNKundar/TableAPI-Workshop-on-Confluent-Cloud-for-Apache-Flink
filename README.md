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
In the current working directory, You'll see a folder **flink-table-api-example** with a maven Java TableAPI code.


## Teardown Resources



