#!/bin/bash

clear
echo "Enter Cluster Name"
read cluster
mkdir ${cluster}_cluster_config

#kubectl create ns dac
#./bin/cbopcfg --no-operator --namespace dac | kubectl create -n dac -f -
echo ''
echo "Enter your Namespace Name"
read ns
kubectl create ns ${ns}

kubectl create -f crd.yaml
./bin/cbopcfg --namespace ${ns} | kubectl -n ${ns} create  -f -
#./bin/cbopcfg --no-admission --namespace ${ns} | kubectl create -n ${ns} -f -

# Create CB Cluster

#kubectl create -f crd.yaml
cp templates/couchbase-cluster_temp.yaml ${cluster}_config/couchbase-cluster_${cluster}.yaml
sed -i '' "s/cb-example/${cluster}/g" ${cluster}_config/couchbase-cluster_${cluster}.yaml
kubectl create -f ${cluster}_config/couchbase-cluster_${cluster}.yaml --namespace ${ns}

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
echo ''
echo "Creating buckets"
kubectl create -f templates/buckets.yaml --namespace ${ns}
kubectl port-forward --namespace ${ns} ${cluster}-0000 8091:8091 &

sleep 60
# Copy Ecomm Data Set (50 Users, 100 Products, 60 Orders, 30 Reviews)
kubectl --namespace ${ns} cp ../data/ecomm ${cluster}-0000:/tmp/ecomm

# Copy Music Data Set (10 Countries, 50 Users, 50 Tracks, 50 Playlists)
kubectl --namespace ${ns} cp ../data/music ${cluster}-0000:/tmp/music

# Copy Contacts Data Set (50 Contacts)
kubectl --namespace ${ns}  cp ../data/contacts ${cluster}-0000:/tmp/contacts

# Import Data set to ecommerce bucket
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/reviews.json -g key::%_id% -t 4"
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/users.json -g key::%_id% -t 4"
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/products.json -g key::%_id% -t 4"
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/orders.json -g key::%_id% -t 4"

# Import Music Data Set
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/countries.json -g key::%_id% -t 4"
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/users.json -g key::%_id% -t 4"
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/tracks.json -g key::%_id% -t 4"
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/playlists.json -g key::%_id% -t 4"


# Import Contacts Dataset
kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b contacts -f list -d file:///tmp/contacts/contacts.json -g key::%contact_id% -t 4"

