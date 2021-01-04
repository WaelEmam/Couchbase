#!/bin/bash

clear
echo "Enter First Cluster Name"
read cluster1
mkdir cluster_configs/couchmart_cluster_config

echo "Enter Second Cluster Name"
read cluster2
#mkdir ${cluster2}_cluster_config

#kubectl create ns dac
#./bin/cbopcfg --no-operator --namespace dac | kubectl create -n dac -f -
echo ''
echo "Enter your Namespace Name"
read ns
kubectl create ns ${ns}

export ns
export cluster1
export cluster2

kubectl create -f operator_2.0/crd.yaml
./operator_2.0/bin/cbopcfg --namespace ${ns} | kubectl -n ${ns} create  -f -
#./bin/cbopcfg --no-admission --namespace ${ns} | kubectl create -n ${ns} -f -

# Create CB Clusters

#kubectl create -f crd.yaml
cp templates/couchbase-cluster_couchmart.yaml cluster_configs/couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml
cp templates/couchbase-cluster_couchmart.yaml cluster_configs/couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml
cp templates/couchmart_buckets.yaml cluster_configs/couchmart_cluster_config/couchmart_buckets_${cluster1}.yaml
cp templates/couchmart_buckets.yaml cluster_configs/couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml

sed -i '' "s/cb-example/${cluster1}/g" cluster_configs/couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml
sed -i '' "s/cb-example/${cluster2}/g" cluster_configs/couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml
sed -i '' "s/cb-example/${cluster1}/g" cluster_configs/couchmart_cluster_config/couchmart_buckets_${cluster1}.yaml
sed -i '' "s/cb-example/${cluster2}/g" cluster_configs/couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml

kubectl -n ${ns} create -f cluster_configs/couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml --namespace ${ns}
sleep 30
kubectl -n ${ns} create -f cluster_configs/couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml --namespace ${ns}

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
echo ''
echo "Creating buckets"
kubectl -n ${ns} create -f cluster_configs/couchmart_cluster_config/couchmart_buckets_${cluster1}.yaml
kubectl -n ${ns} create -f cluster_configs/couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml
kubectl port-forward --namespace ${ns} ${cluster1}-0000 8091:8091 &
kubectl port-forward --namespace ${ns} ${cluster2}-0000 8092:8091 &

kubectl -n ${ns}  create -f templates/couchmart.yml 
kubectl -n ${ns} expose deployment couchmart --type=LoadBalancer --port=8888 --target-port=8888
sleep 20
AWS_IP=`kubectl -n ${ns} get pods -o wide | grep ${cluster1}-0000| awk '{print $6}'`
AZURE_IP=`kubectl -n ${ns} get pods -o wide | grep ${cluster2}-0000| awk '{print $6}'`
couchmart_pod=`kubectl -n ${ns} get pods | grep couchmart- | awk '{print $1}'`
kubectl -n ${ns} exec ${couchmart_pod} -- bash -c "sed -i 's/AWS_NODES.*/AWS_NODES = [\"${AWS_IP}\"]/' couchmart/settings.py"
kubectl -n ${ns} exec ${couchmart_pod} -- bash -c "sed -i 's/AZURE_NODES.*/AZURE_NODES = [\"${AZURE_IP}\"]/' couchmart/settings.py"

kubectl -n ${ns} exec ${couchmart_pod} -- bash -c "python couchmart/create_dataset.py"
kubectl -n ${ns} exec ${couchmart_pod} -- bash -c "cd couchmart; python web-server.py" &

bash demos/couchmart/create_sgw.sh
