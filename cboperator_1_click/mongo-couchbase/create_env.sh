#!/bin/bash


# Create Mysql Pod
kubectl run mongodb --image=mongo:latest
sleep 15

#MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
kubectl cp script.js  ${MONGO_POD}:/tmp/script.js
kubectl cp generated.json ${MONGO_POD}:/tmp/generated.json
kubectl exec ${MONGO_POD} -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"

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

