#!/bin/bash


# Create CB Cluster
kubectl create -f admission.yaml
kubectl create -f crd.yaml
kubectl create -f operator-role.yaml --namespace default
kubectl create -f operator-service-account.yaml --namespace default
kubectl create -f operator-role-binding.yaml --namespace default
kubectl create -f operator-deployment.yaml --namespace default
kubectl create -f secret.yaml
kubectl create -f couchbase-cluster-1.yaml
kubectl create -f couchbase-cluster-2.yaml

# Wait till all pods are up and running
echo "Waiting for Pods to come up"
sleep 120
kubectl port-forward wael-cb-k8s-1-0000 8091:8091 &
kubectl port-forward wael-cb-k8s-2-0000 8092:8091 &


# Copy Ecomm Data Set (50 Users, 100 Products, 60 Orders, 30 Reviews)
#kubectl cp data/ecomm wael-cb-k8s-0000:/tmp/ecomm

# Copy Music Data Set (10 Countries, 50 Users, 50 Tracks, 50 Playlists)
#kubectl cp data/music wael-cb-k8s-0000:/tmp/music

# Copy Contacts Data Set (50 Contacts)
#kubectl cp data/contacts wael-cb-k8s-0000:/tmp/contacts

# Import Data set to ecommerce bucket
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/reviews.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/users.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/products.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/orders.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbindex -auth Administrator:password -type create -bucket couchmart -index category -fields=category"

# Import Music Data Set
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/countries.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/users.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/tracks.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/playlists.json -g key::%_id% -t 4"

#sleep 15

# Import Contacts Dataset
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b contacts -f list -d file:///tmp/contacts/contacts.json -g key::%contact_id% -t 4"


# Create Couchmart 
kubectl create -f couchmart.yml
kubectl expose deployment couchmart --type=LoadBalancer --port=8888 --target-port=8888
sleep 20
AWS_IP=`kubectl get pods -o wide | grep wael-cb-k8s-1-0000| awk '{print $6}'`
AZURE_IP=`kubectl get pods -o wide | grep wael-cb-k8s-2-0000| awk '{print $6}'`
couchmart_pod=`kubectl get pods | grep couchmart | awk '{print $1}'`
kubectl exec ${couchmart_pod} -- bash -c "sed -i 's/AWS_NODES.*/AWS_NODES = [\"${AWS_IP}\"]/' couchmart/settings.py"
kubectl exec ${couchmart_pod} -- bash -c "sed -i 's/AZURE_NODES.*/AZURE_NODES = [\"${AZURE_IP}\"]/' couchmart/settings.py"

kubectl exec ${couchmart_pod} -- bash -c "python couchmart/create_dataset.py"
kubectl exec ${couchmart_pod} -- bash -c "cd couchmart; python web-server.py" &