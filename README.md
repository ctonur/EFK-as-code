# Introduction

The leading open source logging solution, EFK stands for Elasticsearch, Fluentd, and Kibana. EFK is a popular and the best open-source choice for the Kubernetes log aggregation and analysis. EFK deploy and configuration via terraform.

# Components:
## Elastic:

A Basic flask Elasticsearch has been developed in order to match the requirements. 

# notes: if you install on minikube, set to replicas and  minimumMasterNodes. also set to antiAffinity: soft

## Kibana:

Kibana is a free and open user interface that lets you visualize your Elasticsearch data and navigate the Elastic Stack

## Fluentbit:

Fluentbit is an open source data collector for unified logging layer.

## Start Minikube or Kubernetes

### Create a namespace by kubectl which is name monitoring.

kubectl create ns monitoring

### Create EFK on Minikube by Using Terraform

# Terraform Installation:

wget https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip
unzip terraform_0.12.6_linux_amd64.zip
sudo mv terraform /opt/terraform
sudo ln -s /opt/terraform /usr/local/bin/terraform

# Deloyp EFK via terraform:

terraform init
terraform plan
terraform apply -auto-approve


### Create a namespace by kubectl which is name monitoring.

## EFK data retention policy


```
Edit values/elasticsearch.yaml  

firstly following commnad created index lifecycle policy and second curl command creates index templete to binding new indices to life cycle policy

    postStart:
      exec:
        command:
          - bash
          - -c
          - |
            #!/bin/bash
            # Add a template to adjust number of shards/replicas
            TEMPLATE_NAME=fluentbit
            INDEX_PATTERN="logstash-*"
            SHARD_COUNT=1
            REPLICA_COUNT=0
            ES_URL=http://localhost:9200
            while [[ "$(curl -s -o /dev/null -w '%{http_code}\n' $ES_URL)" != "200" ]]; do sleep 1; done
            curl -XPUT "$ES_URL/_ilm/policy/$TEMPLATE_NAME" -H 'Content-Type: application/json' -d'{"policy":{"phases":{"hot":{"actions":{"set_priority":{"priority":100}},"min_age":"0ms"},"delete":{"min_age":"1d","actions":{"delete":{}}}}}}'
            sleep 5
            curl -XPUT "$ES_URL/_template/$TEMPLATE_NAME" -H 'Content-Type: application/json' -d'{"index_patterns":['\""$INDEX_PATTERN"\"'],"settings":{"index":{"lifecycle":{"name":"fluentbit"},"number_of_shards":"1","number_of_replicas":"0"}}}'




```





## EFK data retention policy check via api

elasticsearch@elasticsearch-master-0:~$ curl localhost:9200/_cat/indices
green open .geoip_databases                5_QpsgntSsW4aOA2y2TpxQ 1 0  40   0    38mb    38mb
green open .kibana_task_manager_7.17.3_001 LfLeklaBQ5WBwj6hBtRwCQ 1 0  17 121  76.5kb  76.5kb
green open .apm-custom-link                gq0cxWjWSFiST1qzThxopQ 1 0   0   0    226b    226b
green open logstash-2022.06.28             FnQQgShjS2GsrAUW--ZJpg 1 0 123   0 170.6kb 170.6kb
green open .apm-agent-configuration        H-MgD4_NSQ6c2lwiyEOe8A 1 0   0   0    226b    226b
green open .kibana_7.17.3_001              ufG0s668Ry6UyyUwJxBERg 1 0  11   0   2.3mb   2.3mb
elasticsearch@elasticsearch-master-0:~$ curl localhost:9200/logstash-2022.06.28/_settings
{"logstash-2022.06.28":{"settings":{"index":{"lifecycle":{"name":"fluentbit"},"routing":{"allocation":{"include":{"_tier_preference":"data_content"}}},"number_of_shards":"1","provided_name":"logstash-2022.06.28","creation_date":"1656433329689","priority":"100","number_of_replicas":"0","uuid":"FnQQgShjS2GsrAUW--ZJpg","version":{"created":"7170399"}}}}}elasticsearch@elasticsearch-master-0:~$ 
elasticsearch@elasticsearch-master-0:~$ 
elasticsearch@elasticsearch-master-0:~$ curl localhost:9200/_ilm/policy/fluentbit        
{"fluentbit":{"version":1,"modified_date":"2022-06-28T16:21:49.059Z","policy":{"phases":{"hot":{"min_age":"0ms","actions":{"set_priority":{"priority":100}}},"delete":{"min_age":"1d","actions":{"delete":{"delete_searchable_snapshot":true}}}}},"in_use_by":{"indices":["logstash-2022.06.28"],"data_streams":[],"composable_templates":[]}}}elasticsearch@elasticsearch-master-0:~$



