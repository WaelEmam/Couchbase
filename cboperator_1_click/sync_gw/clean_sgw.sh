#!/bin/bash




kubectl delete -f sgw-load-balancer.yaml
kubectl delete secret sgw-config 
kubectl delete -f sgw-deployment.yaml
