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
echo "Waiting for Pods to start"
sleep 120
kubectl port-forward wael-cb-k8s-0000 8091:8091 &


# Copy Ecomm Data Set (50 Users, 100 Products, 60 Orders, 30 Reviews)
kubectl cp data/ecomm wael-cb-k8s-0000:/tmp/ecomm

# Copy Music Data Set (10 Countries, 50 Users, 50 Tracks, 50 Playlists)
kubectl cp data/music wael-cb-k8s-0000:/tmp/music

# Copy Contacts Data Set (50 Contacts)
kubectl cp data/contacts wael-cb-k8s-0000:/tmp/contacts

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

# LDAP Integration

kubectl run openldap --image=osixia/openldap:1.3.0 --port=389 --env LDAP_ORGANISATION="Couchbase" --env LDAP_DOMAIN="wael.couchbase.com" --env LDAP_ADMIN_PASSWORD="admin123"
kubectl expose deployment openldap --type=LoadBalancer --port=389 --target-port=389
sleep 40
#ldapadd -x -H ldap://localhost:389 -D "cn=admin,dc=wael,dc=couchbase,dc=com" -w admin123 -f output_all.ldif
ldapadd -x -H ldap://localhost:389 -D "cn=admin,dc=wael,dc=couchbase,dc=com" -w admin123 -f ldap.ldif
ldap=`kubectl get pods -o wide | grep open| awk '{print $6}'`

#echo ${ldap}

/Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=wael,dc=couchbase,dc=com' --bind-password 'admin123' --authentication-enabled 1 --user-dn-query 'ou=users,dc=wael,dc=couchbase,dc=com??one?(uid=%u)' --authorization-enabled 1 --group-query 'ou=groups,dc=wael,dc=couchbase,dc=com??one?(member=%D)'
# /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=wael,dc=couchbase,dc=com' --bind-password 'admin123' --authentication-enabled 1

# Set Users Permissions
kubectl exec wael-cb-k8s-0000 -- bash -c "couchbase-cli user-manage -c 127.0.0.1:8091 -u Administrator -p password --set --rbac-username erwin  --rbac-name "Erwin" --roles bucket_admin[music],data_writer[music],fts_admin[music],query_manage_index[music],query_delete[music],query_insert[music],query_select[music],query_update[music]  --auth-domain external"



# Create Couchmart
kubectl create -f couchmart.yml
kubectl expose deployment couchmart --type=LoadBalancer --port=8888 --target-port=8888
sleep 20
IP=`kubectl get pods -o wide | grep wael-cb-k8s-0000| awk '{print $6}'`
couchmart_pod=`kubectl get pods | grep couchmart | awk '{print $1}'`
kubectl exec ${couchmart_pod} -- bash -c "sed -i 's/AWS_NODES.*/AWS_NODES = [\"${IP}\"]/' couchmart/settings.py"

kubectl exec ${couchmart_pod} -- bash -c "python couchmart/create_dataset.py"
kubectl exec ${couchmart_pod} -- bash -c "cd couchmart; python web-server.py"
