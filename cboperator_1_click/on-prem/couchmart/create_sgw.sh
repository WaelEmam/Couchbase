#!/bin/bash


kubectl create secret generic sgw-config --from-file sgw-config.json

kubectl create -f sgw-deployment.yaml

kubectl create -f sgw-load-balancer.yaml

