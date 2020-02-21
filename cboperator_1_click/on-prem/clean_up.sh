#!/bin/bash


# Clean up

kubectl delete -f couchbase-cluster.yaml
kubectl delete -f secret.yaml
kubectl delete -f operator-role-binding.yaml
kubectl delete -f operator-role.yaml
kubectl delete -f operator-deployment.yaml
kubectl delete -f crd.yaml
kubectl delete -f admission.yaml
kubectl delete -f operator-service-account.yaml

