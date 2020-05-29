#!/bin/bash

clear
echo "Enter First Cluster Name"
read cluster1
mkdir couchmart_cluster_config

echo "Enter Second Cluster Name"
read cluster2
#mkdir ${cluster2}_cluster_config

#kubectl create ns dac
#./bin/cbopcfg --no-operator --namespace dac | kubectl create -n dac -f -
echo ''
echo "Enter your Namespace Name"
read ns
kubectl create ns ${ns}

kubectl create -f crd.yaml
./bin/cbopcfg --namespace ${ns} | kubectl -n ${ns} create  -f -
#./bin/cbopcfg --no-admission --namespace ${ns} | kubectl create -n ${ns} -f -

# Create CB Clusters

#kubectl create -f crd.yaml
cp templates/couchbase-cluster_couchmart.yaml couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml
cp templates/couchbase-cluster_couchmart.yaml couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml
cp templates/couchmart_buckets.yaml couchmart_cluster_config/couchmart_buckets_${cluster1}.yaml
cp templates/couchmart_buckets.yaml couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml

sed -i '' "s/cb-example/${cluster1}/g" couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml
sed -i '' "s/cb-example/${cluster2}/g" couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml
sed -i '' "s/cb-example/${cluster1}/g" couchmart_cluster_config/couchmart_buckets_${cluster1}.yaml
sed -i '' "s/cb-example/${cluster2}/g" couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml

kubectl -n ${ns} create -f couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml --namespace ${ns}
kubectl -n ${ns} create -f couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml --namespace ${ns}

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
echo ''
echo "Creating buckets"
kubectl -n ${ns} create -f couchmart_cluster_config/couchmart_buckets_${cluster1}.yaml
kubectl -n ${ns} create -f couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml
kubectl port-forward --namespace ${ns} ${cluster1}-0000 8091:8091 &
kubectl port-forward --namespace ${ns} ${cluster2}-0000 8092:8091 &

kubectl -n ${ns}  create -f ../couchmart/couchmart.yml 
kubectl -n ${ns} expose deployment couchmart --type=LoadBalancer --port=8888 --target-port=8888
sleep 20
AWS_IP=`kubectl -n ${ns} get pods -o wide | grep ${cluster1}-0000| awk '{print $6}'`
AZURE_IP=`kubectl -n ${ns} get pods -o wide | grep ${cluster2}-0000| awk '{print $6}'`
couchmart_pod=`kubectl -n ${ns} get pods | grep couchmart- | awk '{print $1}'`
kubectl -n ${ns} exec ${couchmart_pod} -- bash -c "sed -i 's/AWS_NODES.*/AWS_NODES = [\"${AWS_IP}\"]/' couchmart/settings.py"
kubectl -n ${ns} exec ${couchmart_pod} -- bash -c "sed -i 's/AZURE_NODES.*/AZURE_NODES = [\"${AZURE_IP}\"]/' couchmart/settings.py"

kubectl -n ${ns} exec ${couchmart_pod} -- bash -c "python couchmart/create_dataset.py"
kubectl -n ${ns} exec ${couchmart_pod} -- bash -c "cd couchmart; python web-server.py" &

#sleep 60
# Copy Ecomm Data Set (50 Users, 100 Products, 60 Orders, 30 Reviews)
#kubectl --namespace ${ns} cp ../data/ecomm ${cluster}-0000:/tmp/ecomm

# Copy Music Data Set (10 Countries, 50 Users, 50 Tracks, 50 Playlists)
#kubectl --namespace ${ns} cp ../data/music ${cluster}-0000:/tmp/music

# Copy Contacts Data Set (50 Contacts)
#kubectl --namespace ${ns}  cp ../data/contacts ${cluster}-0000:/tmp/contacts

# Import Data set to ecommerce bucket
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/reviews.json -g key::%_id% -t 4"
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/users.json -g key::%_id% -t 4"
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/products.json -g key::%_id% -t 4"
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/orders.json -g key::%_id% -t 4"

# Import Music Data Set
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/countries.json -g key::%_id% -t 4"
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/users.json -g key::%_id% -t 4"
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/tracks.json -g key::%_id% -t 4"
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/playlists.json -g key::%_id% -t 4"


# Import Contacts Dataset
#kubectl exec --namespace ${ns} ${cluster}-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b contacts -f list -d file:///tmp/contacts/contacts.json -g key::%contact_id% -t 4"

