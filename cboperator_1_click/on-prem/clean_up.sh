#!/bin/bash


# Clean up

port_forward=`ps -ef | grep 8091| grep -v grep| awk '{print $2}'`
kill -9 ${port_forward}

kubectl delete -f couchbase-cluster.yaml
kubectl delete -f operator_files/secret.yaml
kubectl delete -f operator_files/operator-role-binding.yaml
kubectl delete -f operator_files/operator-role.yaml
kubectl delete -f operator_files/operator-deployment.yaml
kubectl delete -f operator_files/crd.yaml
kubectl delete -f operator_files/admission.yaml
kubectl delete -f operator_files/operator-service-account.yaml
#kubectl delete -f couchmart.yml
kubectl delete -f couchmart/couchbase-cluster-1.yaml
kubectl delete -f couchmart/couchbase-cluster-2.yaml

kubectl delete deployment openldap
kubectl delete svc openldap	    
kubectl delete deployment nifi
kubectl delete svc nifi
kubectl delete pod mysql
kubectl delete svc mysql
kubectl delete svc mongodb
kubectl delete pod mongodb
kubectl delete svc couchmovies-web
kubectl delete svc couchmovies-rest
