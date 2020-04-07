#!/bin/bash


# Clean up

port_forward=`ps -ef | grep 8091| grep -v grep| awk '{print $2}'`
kill -9 ${port_forward}

kubectl delete -f couchbase-cluster.yaml
kubectl delete -f secret.yaml
kubectl delete -f operator-role-binding.yaml
kubectl delete -f operator-role.yaml
kubectl delete -f operator-deployment.yaml
kubectl delete -f crd.yaml
kubectl delete -f admission.yaml
kubectl delete -f operator-service-account.yaml
#kubectl delete -f couchmart.yml

kubectl delete deployment openldap
kubectl delete svc openldap	    
kubectl delete deployment nifi
kubectl delete svc nifi
kubectl delete pod mysql
kubectl delete svc mysql
kubectl delete svc mongodb
kubectl delete pod mongodb
