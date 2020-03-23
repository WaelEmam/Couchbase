#!/bin/bash


# Create Mysql Pod
kubectl run mysql --image=mysql:latest --env MYSQL_ROOT_PASSWORD=admin123 --port=3306
sleep 15
MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
kubectl cp sakila-db/ ${MYSQL_POD}:/tmp/sakila-db
kubectl exec ${MYSQL_POD} -- bash -c "cd /tmp/sakila-db; mysql -uroot -padmin123 < sakila-schema.sql; mysql -uroot -padmin123 < sakila-data.sql;"


# Create Nifi Pod
kubectl create -f nifi.yaml
sleep 15
kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
kubectl cp mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp

sleep 15

# Create CB Cluster

kubectl create -f admission.yaml
kubectl create -f crd.yaml
kubectl create -f operator-role.yaml --namespace default
kubectl create -f operator-service-account.yaml --namespace default
kubectl create -f operator-role-binding.yaml --namespace default
kubectl create -f operator-deployment.yaml --namespace default
kubectl create -f secret.yaml
kubectl create -f couchbase-cluster.yaml

# Wait till all pods are up and running
sleep 120
kubectl port-forward wael-cb-k8s-0000 8091:8091 &

