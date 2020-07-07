#!/bin/bash


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
echo " "
echo "Waiting for Pods to come up"
sleep 120
kubectl port-forward wael-cb-k8s-0000 8091:8091 &


# Create Couchmart 
kubectl create -f couchmovies.yaml
sleep 10
kubectl expose deployment couchmovies --type=LoadBalancer --port=8000 --target-port=8000
#AWS_IP=`kubectl get pods -o wide | grep wael-cb-k8s-1-0000| awk '{print $6}'`
#AZURE_IP=`kubectl get pods -o wide | grep wael-cb-k8s-2-0000| awk '{print $6}'`
#couchmovies_pod=`kubectl get pods | grep couchmart | awk '{print $1}'`
#kubectl exec ${couchmart_pod} -- bash -c "sed -i 's/AWS_NODES.*/AWS_NODES = [\"${AWS_IP}\"]/' couchmart/settings.py"
#kubectl exec ${couchmart_pod} -- bash -c "sed -i 's/AZURE_NODES.*/AZURE_NODES = [\"${AZURE_IP}\"]/' couchmart/settings.py"

#kubectl exec ${couchmart_pod} -- bash -c "python couchmart/create_dataset.py"
#kubectl exec ${couchmart_pod} -- bash -c "cd couchmart; python web-server.py" &
