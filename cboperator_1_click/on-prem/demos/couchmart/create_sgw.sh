#!/bin/bash


kubectl create secret generic sgw-config --from-file demos/couchmart/sgw-config-xattrs.json -n ${ns}

kubectl create -f demos/couchmart/sgw-deployment.yaml -n ${ns}

kubectl create -f demos/couchmart/sgw-load-balancer.yaml -n ${ns}

