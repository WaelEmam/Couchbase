#!/bin/bash

clear
echo "Enter Cluster Name"
read cluster

# Create CB Cluster

kubectl create -f operator_files/admission.yaml
kubectl create -f operator_files/crd.yaml
kubectl create -f operator_files/operator-role.yaml --namespace default
kubectl create -f operator_files/operator-service-account.yaml --namespace default
kubectl create -f operator_files/operator-role-binding.yaml --namespace default
kubectl create -f operator_files/operator-deployment.yaml --namespace default
kubectl create -f operator_files/secret.yaml
yq w templates/couchbase-cluster_temp.yaml "metadata.name" "${cluster}" > couchbase-cluster_${cluster}.yaml
kubectl create -f couchbase-cluster_${cluster}.yaml

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
kubectl port-forward ${cluster}-0000 8091:8091 &


# Copy Ecomm Data Set (50 Users, 100 Products, 60 Orders, 30 Reviews)
kubectl cp data/ecomm ${cluster}-0000:/tmp/ecomm

# Copy Music Data Set (10 Countries, 50 Users, 50 Tracks, 50 Playlists)
kubectl cp data/music ${cluster}-0000:/tmp/music

# Copy Contacts Data Set (50 Contacts)
kubectl cp data/contacts ${cluster}-0000:/tmp/contacts

# Import Data set to ecommerce bucket
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/reviews.json -g key::%_id% -t 4"
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/users.json -g key::%_id% -t 4"
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/products.json -g key::%_id% -t 4"
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/orders.json -g key::%_id% -t 4"

# Import Music Data Set
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/countries.json -g key::%_id% -t 4"
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/users.json -g key::%_id% -t 4"
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/tracks.json -g key::%_id% -t 4"
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/playlists.json -g key::%_id% -t 4"


# Import Contacts Dataset
kubectl exec ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b contacts -f list -d file:///tmp/contacts/contacts.json -g key::%contact_id% -t 4"

