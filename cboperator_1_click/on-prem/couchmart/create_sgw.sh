#!/bin/bash


kubectl create secret generic sgw-config --from-file couchmart/sgw-config-xattrs.json

kubectl create -f couchmart/sgw-deployment.yaml

kubectl create -f couchmart/sgw-load-balancer.yaml

