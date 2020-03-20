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
#kubectl create -f nifi.yaml

# Wait till all pods are up and running
sleep 120
kubectl port-forward wael-cb-k8s-0000 8091:8091 &


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

sleep 15

# Import Contacts Dataset
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b contacts -f list -d file:///tmp/contacts/contacts.json -g key::%contact_id% -t 4"


# Create Nifi Pod
kubectl create -f nifi.yaml
kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
#sleep 20
#IP=`kubectl get pods -o wide | grep wael-cb-k8s-0000| awk '{print $6}'`
#couchmart_pod=`kubectl get pods | grep couchmart | awk '{print $1}'`
#kubectl exec ${couchmart_pod} -- bash -c "sed -i 's/AWS_NODES.*/AWS_NODES = [\"${IP}\"]/' couchmart/settings.py"

#kubectl exec ${couchmart_pod} -- bash -c "python couchmart/create_dataset.py"
#kubectl exec ${couchmart_pod} -- bash -c "cd couchmart; python web-server.py"


# Create Mysql Pod
kubectl run mysql --image=mysql:latest --env MYSQL_ROOT_PASSWORD=admin123 --port=3306
kubectl cp test_db/ mysql-7b9b8b5bb7-psgct:/tmp/test_db
kubectl exec mysql-7b9b8b5bb7-psgct -- bash -c "cd /tmp/test_db; mysql -uroot -padmin123 < employees.sql"
MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
#kubectl expose deployment mysql --type=LoadBalancer --port=3306 --target-port=3306
