#!/bin/bash

#clear
#echo "Enter Cluster Name"
#read cluster

# Create CB Cluster

kubectl create -f operator_files/admission.yaml
kubectl create -f operator_files/crd.yaml
kubectl create -f operator_files/operator-role.yaml --namespace default
kubectl create -f operator_files/operator-service-account.yaml --namespace default
kubectl create -f operator_files/operator-role-binding.yaml --namespace default
kubectl create -f operator_files/operator-deployment.yaml --namespace default
kubectl create -f operator_files/secret.yaml
#yq w templates/couchbase-cluster_temp.yaml "metadata.name" "${cluster}" > couchbase-cluster_${cluster}.yaml
cd mysql-kafka-cb
kubectl create -f couchbase-cluster_mysql-kafka-cb.yaml

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
kubectl port-forward mysql-kafka-cb-0000 8091:8091 &

# Create Zookeeper 

kubectl run zookeeper --image=debezium/zookeeper:latest --env ZOOKEEPER_TICK_TIME=2000 --env ZOOKEEPER_CLIENT_PORT=2181
sleep 5
kubectl expose deployment zookeeper --type=LoadBalancer --port=2181 --target-port=2181

# Create Kafka pod and varius topics

kubectl run kafka --image=debezium/kafka:latest --restart=Never --port=9092 --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --env KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "kafka", "subdomain": "example"}}'
sleep 15
kubectl expose pod kafka --type=LoadBalancer --port=9092 --target-port=9092
kubectl exec kafka -- bash -c "./bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --topic my_connect_configs"
kubectl exec kafka -- bash -c "./bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --topic my_connect_offsets"
kubectl exec kafka -- bash -c "./bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --topic my_connect_statuses"
kubectl exec kafka -- bash -c "./bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --topic schema-changes.inventory"
kubectl exec kafka -- bash -c "./bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --topic mysql_inventory"



kubectl run mysql --image=debezium/example-mysql:latest --restart=Never --port=3306 --env MYSQL_ROOT_PASSWORD=debezium --env MYSQL_USER=mysqluser --env MYSQL_PASSWORD=mysqlpw --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
kubectl expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306


kubectl run connect --image=waelemam/couchbase-kafka-connect:0.1 --restart=Never --port 8083 --env GROUP_ID=1 --env CONFIG_STORAGE_TOPIC=my_connect_configs --env OFFSET_STORAGE_TOPIC=my_connect_offsets --env STATUS_STORAGE_TOPIC=my_connect_statuses --env CONNECT_BOOTSTRAP_SERVERS=kafka:9092  --overrides='{ "apiVersion": "v1", "spec": {"hostname": "connect", "subdomain": "example"}}'
kubectl expose pod connect --type=LoadBalancer --port=8083 --target-port=8083
sleep 15

curl -H "Accept:application/json" -H "Content-Type:application/json" -POST -d @./mysql-kafka-connector http://localhost:8083/connectors/
curl -H "Accept:application/json" -H "Content-Type:application/json" -POST -d @./kafka-cb-connector http://localhost:8083/connectors/



#curl -H "Accept:application/json" localhost:8083/
#curl -H "Accept:application/json" localhost:8083/connectors

