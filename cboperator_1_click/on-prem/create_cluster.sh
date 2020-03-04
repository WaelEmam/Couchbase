#!/bin/bash


# Clean up

#kubectl delete -f couchbase-cluster.yaml
#kubectl delete -f secret.yaml
#kubectl delete -f operator-role-binding.yaml
#kubectl delete -f operator-role.yaml
#kubectl delete -f operator-deployment.yaml
#kubectl delete -f crd.yaml
#kubectl delete -f admission.yaml
#kubectl delete -f operator-service-account.yaml

# Create CB Cluster

kubectl create -f admission.yaml
kubectl create -f crd.yaml
kubectl create -f operator-role.yaml --namespace default
kubectl create -f operator-service-account.yaml --namespace default
kubectl create -f operator-role-binding.yaml --namespace default
kubectl create -f operator-deployment.yaml --namespace default
kubectl create -f secret.yaml
kubectl create -f couchbase-cluster.yaml

#sleep 120
#kubectl cp /Users/waelemam/mock_data/ecomm wael-cb-k8s-0000:/tmp/ecomm
kubectl port-forward wael-cb-k8s-0000 8091:8091 &

ldap=`kubectl get pods -o wide | grep open| awk '{print $6}'`

echo ${ldap}

/Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=wael,dc=couchbase,dc=com' --bind-password 'admin123' --authentication-enabled 1 --user-dn-query 'ou=users,dc=wael,dc=couchbase,dc=com??one?(uid=%u)' --authorization-enabled 1 --group-query 'ou=groups,dc=wael,dc=couchbase,dc=com??one?(member=%D)'

# cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/ecom_products.json -g key::%_id% -t 4
# cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/ecom_reviews.json -g key::%_id% -t 4
# cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/ecom_orders.json -g key::%_id% -t 4
# cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file://tmp/ecomm/ecom_users.json -g key::%_id% -t 4
