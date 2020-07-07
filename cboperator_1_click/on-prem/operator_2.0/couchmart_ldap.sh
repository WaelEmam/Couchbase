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

echo ""

echo "Enter LDAP Domain"
read ldap_domain
kubectl create -f crd.yaml
./bin/cbopcfg --namespace ${ns} | kubectl -n ${ns} create  -f -
#./bin/cbopcfg --no-admission --namespace ${ns} | kubectl create -n ${ns} -f -

# Create CB Clusters

#kubectl create -f crd.yaml
cp templates/couchbase-cluster_couchmart_ldap.yaml couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml
cp templates/couchbase-cluster_couchmart_ldap.yaml couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml
#cp templates/couchmart_buckets.yaml couchmart_cluster_config/couchmart_buckets.yaml
#cp templates/couchmart_buckets.yaml couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml

sed -i '' "s/cb-example/${cluster1}/g" couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml
sed -i '' "s/cb-example/${cluster2}/g" couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml
#sed -i '' "s/cb-example/${cluster1}/g" couchmart_cluster_config/couchmart_buckets_${cluster1}.yaml
#sed -i '' "s/cb-example/${cluster2}/g" couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml
sed -i '' "s/dc=wael/dc=${ldap_domain}/g" couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml
sed -i '' "s/dc=wael/dc=${ldap_domain}/g" couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml

kubectl -n ${ns} create -f couchmart_cluster_config/couchbase-cluster_${cluster1}.yaml --namespace ${ns}
kubectl -n ${ns} create -f couchmart_cluster_config/couchbase-cluster_${cluster2}.yaml --namespace ${ns}

# Wait till all pods are up and running
echo " "
echo "Waiting for Pods to start"
sleep 120
echo ''
echo "Creating buckets"
kubectl -n ${ns} create -f templates/couchmart_buckets.yaml
#kubectl -n ${ns} create -f couchmart_cluster_config/couchmart_buckets_${cluster2}.yaml
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

