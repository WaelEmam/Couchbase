#!/bin/bash


# Create CB Cluster
kubectl create -f operator_files/admission.yaml
kubectl create -f operator_files/crd.yaml
kubectl create -f operator_files/operator-role.yaml --namespace default
kubectl create -f operator_files/operator-service-account.yaml --namespace default
kubectl create -f operator_files/operator-role-binding.yaml --namespace default
kubectl create -f operator_files/operator-deployment.yaml --namespace default
kubectl create -f operator_files/secret.yaml
kubectl create -f couchmart/couchbase-cluster-1.yaml
kubectl create -f couchmart/couchbase-cluster-2.yaml

# Wait till all pods are up and running
echo "Waiting for Pods to come up"
sleep 120
kubectl port-forward wael-cb-k8s-1-0000 8091:8091 &
kubectl port-forward wael-cb-k8s-2-0000 8092:8091 &


# Create Couchmart 
kubectl create -f couchmart/couchmart.yml
kubectl expose deployment couchmart --type=LoadBalancer --port=8888 --target-port=8888
sleep 20
AWS_IP=`kubectl get pods -o wide | grep wael-cb-k8s-1-0000| awk '{print $6}'`
AZURE_IP=`kubectl get pods -o wide | grep wael-cb-k8s-2-0000| awk '{print $6}'`
couchmart_pod=`kubectl get pods | grep couchmart | awk '{print $1}'`
kubectl exec ${couchmart_pod} -- bash -c "sed -i 's/AWS_NODES.*/AWS_NODES = [\"${AWS_IP}\"]/' couchmart/settings.py"
kubectl exec ${couchmart_pod} -- bash -c "sed -i 's/AZURE_NODES.*/AZURE_NODES = [\"${AZURE_IP}\"]/' couchmart/settings.py"

kubectl exec ${couchmart_pod} -- bash -c "python couchmart/create_dataset.py"
kubectl exec ${couchmart_pod} -- bash -c "cd couchmart; python web-server.py" &
bash create_sgw.sh
