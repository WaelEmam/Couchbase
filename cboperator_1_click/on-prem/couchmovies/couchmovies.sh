#!/bin/bash

# Create CB Cluster

kubectl create -f admission.yaml
kubectl create -f crd.yaml
kubectl create -f operator-role.yaml --namespace default
kubectl create -f operator-service-account.yaml --namespace default
kubectl create -f operator-role-binding.yaml --namespace default
kubectl create -f operator-deployment.yaml --namespace default
kubectl create -f secret.yaml
kubectl create -f couchmovies/couchbase-cluster.yaml

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
kubectl port-forward wael-cb-k8s-0000 8091:8091 &

kubectl create -f couchmovies/couchmovies.yaml
kubectl expose deployment couchmovies --type=LoadBalancer --port=8000 --target-port=8000 --name=couchmovies-web
kubectl expose deployment couchmovies --type=LoadBalancer --port=8000 --target-port=8080 --name=couchmovies-rest

