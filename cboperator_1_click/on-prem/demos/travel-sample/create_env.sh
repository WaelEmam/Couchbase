#!/bin/bash

clear
#echo "Enter Cluster Name"
#read cluster
#mkdir ${cluster}_cluster_config
cluster=cb-server
#kubectl create ns dac
#./bin/cbopcfg --no-operator --namespace dac | kubectl create -n dac -f -
#echo ''
#echo "Enter your Namespace Name"
#read ns
ns=cb-server
kubectl create ns ${ns}

kubectl create -f operator_2.0/crd.yaml
./operator_2.0/bin/cbopcfg --namespace ${ns} | kubectl -n ${ns} create  -f -
#./bin/cbopcfg --no-admission --namespace ${ns} | kubectl create -n ${ns} -f -

# Create CB Cluster

#kubectl create -f crd.yaml
#cp templates/couchbase-cluster_temp.yaml ${cluster}_cluster_config/couchbase-cluster_${cluster}.yaml
#sed -i '' "s/cb-example/${cluster}/g" ${cluster}_cluster_config/couchbase-cluster_${cluster}.yaml
kubectl create -f  templates/travel-sample-cluster_temp.yaml --namespace ${ns}

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
echo ''
#echo "Creating buckets"
#kubectl create -f templates/buckets.yaml --namespace ${ns}
kubectl port-forward --namespace ${ns} ${cluster}-0000 8091:8091 &
sleep 20
curl -X POST -u Administrator:password http://localhost:8091/sampleBuckets/install -d '["travel-sample"]'
sleep 20
bash demos/travel-sample/create_sgw.sh

sleep 20

kubectl -n cb-server exec sync-gateway -c try-cb-python -- bash -c "curl -XPUT -H "Content-type:application/json" http://Administrator:password@cb-server-0003.cb-server.cb-server.svc:8094/api/index/hotels -d @fts-hotels-index.json"

kubectl port-forward -n cb-server sync-gateway 8080:8080 &
kubectl port-forward -n cb-server sync-gateway 4984:4984 &
kubectl port-forward -n cb-server sync-gateway 4985:4985 &




