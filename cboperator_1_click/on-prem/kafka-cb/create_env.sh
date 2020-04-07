#!/bin/bash


kubectl run zookeeper --image=confluentinc/cp-zookeeper:latest --env ZOOKEEPER_TICK_TIME=2000 --env ZOOKEEPER_CLIENT_PORT=2181
sleep 5
kubectl expose deployment zookeeper --type=LoadBalancer --port=2181 --target-port=2181


#ZK_IP=`kubectl get pods -o wide| grep zookeeper| awk '{print $6}'`
#ZK_POD=`kubectl get pods -o wide| grep zookeeper | awk '{print $1}'`

#KAFKA_POD=`kubectl get pods -o wide| grep kafka | awk '{print $1}'`
kubectl run kafka --image=confluentinc/cp-kafka:latest --restart=Never --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --env KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT --env KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092 --env KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "kafka", "subdomain": "example"}}'
KAFKA_POD=`kubectl get pods -o wide| grep kafka | awk '{print $1}'`

sleep 15

kubectl expose pod kafka --type=LoadBalancer --port=29092 --target-port=29092


#kubectl run schema-registry --image=confluentinc/cp-schema-registry:latest --env SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=zookeeper:2181 --env SCHEMA_REGISTRY_HOST_NAME=localhost --env SCHEMA_REGISTRY_LISTENERS=http://localhost:8081
#SCHEMA_IP=`kubectl get pods -o wide| grep schema| awk '{print $6}'`
#SCHEMA_POD=`kubectl get pods -o wide| grep schema | awk '{print $1}'`



kubectl exec ${KAFKA_POD} -- bash -c "kafka-topics --create --topic quickstart-avro-offsets --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181"
#kubectl exec ${KAFKA_POD} -- bash -c "kafka-topics --create --topic quickstart-avro-config --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181"
#kubectl exec ${KAFKA_POD} -- bash -c "kafka-topics --create --topic quickstart-avro-status --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181"


#kubectl run schema-registry --image=confluentinc/cp-schema-registry:latest --env SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=zookeeper:2181 --env SCHEMA_REGISTRY_HOST_NAME=localhost --env SCHEMA_REGISTRY_LISTENERS=http://localhost:8081
#sleep 10
#kubectl expose deployment schema-registry --port=8081 --target-port=8081

#kubectl run kafka-connect-avro --image=confluentinc/cp-kafka-connect:latest --env CONNECT_BOOTSTRAP_SERVERS=kafka:29092 --env CONNECT_REST_PORT=8083   --env CONNECT_GROUP_ID="quickstart-avro"   --env CONNECT_CONFIG_STORAGE_TOPIC="quickstart-avro-config"   --env CONNECT_OFFSET_STORAGE_TOPIC="quickstart-avro-offsets"   --env CONNECT_STATUS_STORAGE_TOPIC="quickstart-avro-status"   --env CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1   --env CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1   --env CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1   --env CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter"   --env CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter"   --env CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://localhost:8081"   --env CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://localhost:8081"   --env CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter"   --env CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter"   --env CONNECT_REST_ADVERTISED_HOST_NAME="localhost"   --env CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG   --env CONNECT_PLUGIN_PATH=/usr/share/java,/etc/kafka-connect/jars
#CONNECT_POD=`kubectl get pods -o wide| grep kafka-connect | awk '{print $1}'`

#sleep 10

#kubectl cp mysql-connector-java-8.0.19.jar  ${CONNECT_POD}:/etc/kafka-connect/jars/mysql-connector-java-8.0.19.jar

#kubectl run mysql --image=mysql:latest --env MYSQL_ROOT_PASSWORD=admin123 --port=3306
#sleep 5
#MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
#MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`

#https://docs.confluent.io/5.0.0/installation/docker/docs/installation/connect-avro-jdbc.html
