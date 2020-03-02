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

sleep 120
kubectl cp /Users/waelemam/mock_data/ecomm wael-cb-k8s-0000:/tmp/ecomm
kubectl port-forward wael-cb-k8s-0000 8091:8091

# cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/ecom_products.json -g key::%_id% -t 4
# cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/ecom_reviews.json -g key::%_id% -t 4
# cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/ecom_orders.json -g key::%_id% -t 4
# cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file://tmp/ecomm/ecom_users.json -g key::%_id% -t 4
