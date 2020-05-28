#!/bin/bash

echo "Enter Cluster Name"
read cluster
echo " "
echo "Enter LDAP Domain Name:"
read ldap_domain
echo " "
#echo "Enter LDAP Password"
#read ldap_pass
#echo ''
echo "Enter your Namespace Name"
read ns

#kubectl create ns dac
#./bin/cbopcfg --no-operator --namespace dac | kubectl create -n dac -f -
kubectl create -f crd.yaml

kubectl create ns ${ns}
#./bin/cbopcfg --no-admission --namespace ${ns} | kubectl create -n ${ns} -f -
./bin/cbopcfg --namespace ${ns} | kubectl -n ${ns} create  -f -
# Create CB Cluster
#kubectl create -f crd.yaml
cp templates/couchbase-cluster_ldap_temp.yaml couchbase-cluster_ldap_${cluster}.yaml
sed -i '' "s/cb-example/${cluster}/g" couchbase-cluster_ldap_${cluster}.yaml
sed -i '' "s/dc=wael/dc=${ldap_domain}/g" couchbase-cluster_ldap_${cluster}.yaml
kubectl create -f couchbase-cluster_ldap_${cluster}.yaml --namespace ${ns}

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
echo ''
echo "Creating buckets"
kubectl create -f templates/buckets.yaml --namespace ${ns}
kubectl port-forward --namespace ${ns} ${cluster}-0000 8091:8091 &

sleep 45
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


# LDAP Integration

kubectl run  openldap --image=osixia/openldap:1.3.0 --restart=Never --port=389 --env LDAP_ORGANISATION="Couchbase" --env LDAP_DOMAIN="${ldap_domain}.couchbase.com" --env LDAP_ADMIN_PASSWORD="password"
kubectl expose pod openldap --type=LoadBalancer --port=389 --target-port=389
sleep 40
sed  "s/dc=wael/dc=${ldap_domain}/g" "../ldap.ldif" | tee ldap_test
#ldapadd -x -H ldap://localhost:389 -D "cn=admin,dc=wael,dc=couchbase,dc=com" -w admin123 -f output_all.ldif
ldapadd -x -H ldap://localhost:389 -D "cn=admin,dc=${ldap_domain},dc=couchbase,dc=com" -w password -f ldap_test
#ldap=`kubectl get pods -o wide | grep open| awk '{print $6}'`
cp templates/groups.yaml groups_${cluster}.yaml
sed -i '' "s/dc=wael/dc=${ldap_domain}/g" groups_${cluster}.yaml
kubectl create -f groups_${cluster}.yaml -n ${ns}

#/Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=${ldap_domain},dc=couchbase,dc=com' --bind-password '${ldap_pass}' --authentication-enabled 1 --user-dn-query 'ou=users,dc=${ldap_domain},dc=couchbase,dc=com??one?(uid=%u)' --authorization-enabled 1 --group-query 'ou=groups,dc=${ldap_domain},dc=couchbase,dc=com??one?(member=%D)'
# /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=wael,dc=couchbase,dc=com' --bind-password 'admin123' --authentication-enabled 1

# Set Users Permissions
#kubectl exec ${cluster}-0000 -- bash -c "couchbase-cli user-manage -c 127.0.0.1:8091 -u Administrator -p password --set --rbac-username erwin  --rbac-name "Erwin" --roles bucket_admin[couchmart],data_writer[couchmart],fts_admin[couchmart],query_manage_index[couchmart],query_delete[couchmart],query_insert[couchmart],query_select[couchmart],query_update[couchmart]  --auth-domain external"

#kubectl exec ${cluster}-0000 -- bash -c "couchbase-cli user-manage -c 127.0.0.1:8091 -u Administrator -p password --set --rbac-username wael  --rbac-name "Wael" --roles bucket_admin[contacts],data_writer[contacts],fts_admin[contacts],query_manage_index[contacts],query_delete[contacts],query_insert[contacts],query_select[contacts],query_update[contacts]  --auth-domain external"

#kubectl exec ${cluster}-0000 -- bash -c "couchbase-cli user-manage -c 127.0.0.1:8091 -u Administrator -p password --set --rbac-username peter  --rbac-name "Peter" --roles bucket_admin[music],data_writer[music],fts_admin[music],query_manage_index[music],query_delete[music],query_insert[music],query_select[music],query_update[music]  --auth-domain external"
