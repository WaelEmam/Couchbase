#!/bin/bash


# Clean up

port_forward=`ps -ef | grep 8091| grep -v grep| awk '{print $2}'`
kill -9 ${port_forward}

kubectl delete -f couchbase-cluster-1.yaml
kubectl delete -f couchbase-cluster-2.yaml
kubectl delete -f secret.yaml
kubectl delete -f operator-role-binding.yaml
kubectl delete -f operator-role.yaml
kubectl delete -f operator-deployment.yaml
kubectl delete -f crd.yaml
kubectl delete -f admission.yaml
kubectl delete -f operator-service-account.yaml
kubectl delete -f couchmart.yml
kubectl delete svc couchmart
kubectl delete -f sgw-load-balancer.yaml
kubectl delete secret sgw-config
kubectl delete -f sgw-deployment.yaml
