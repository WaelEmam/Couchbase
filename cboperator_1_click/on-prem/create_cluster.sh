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
sleep 120

kubectl port-forward wael-cb-k8s-0000 8091:8091 &


# LDAP Integration
ldap=`kubectl get pods -o wide | grep open| awk '{print $6}'`

#echo ${ldap}

/Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=wael,dc=couchbase,dc=com' --bind-password 'admin123' --authentication-enabled 1 --user-dn-query 'ou=users,dc=wael,dc=couchbase,dc=com??one?(uid=%u)' --authorization-enabled 1 --group-query 'ou=groups,dc=wael,dc=couchbase,dc=com??one?(member=%D)'
# /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=wael,dc=couchbase,dc=com' --bind-password 'admin123' --authentication-enabled 1


# Copy Ecomm Data Set (50 Users, 100 Products, 60 Orders, 30 Reviews)
kubectl cp /Users/waelemam/mock_data/ecomm wael-cb-k8s-0000:/tmp/ecomm

# Copy Music Data Set (10 Countries, 50 Users, 50 Tracks, 50 Playlists)
kubectl cp /Users/waelemam/mock_data/music wael-cb-k8s-0000:/tmp/music

# Copy Contacts Data Set (50 Contacts)
kubectl cp /Users/waelemam/mock_data/contacts wael-cb-k8s-0000:/tmp/contacts

# Import Data set to ecommerce bucket
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/reviews.json -g key::%_id% -t 4"
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/users.json -g key::%_id% -t 4"
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/products.json -g key::%_id% -t 4"
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/orders.json -g key::%_id% -t 4"

# Import Music Data Set
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/countries.json -g key::%_id% -t 4"
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/users.json -g key::%_id% -t 4"
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/tracks.json -g key::%_id% -t 4"
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/playlists.json -g key::%_id% -t 4"


# Import Contacts Dataset
kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b contacts -f list -d file:///tmp/contacts/contacts.json -g key::%contact_id% -t 4"


