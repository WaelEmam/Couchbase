#!/bin/bash


kubectl create secret generic sgw-config --from-file demos/travel-sample/sync-gateway-config-travelsample.json -n cb-server

kubectl create -f demos/travel-sample/sgw-pod.yaml -n cb-server

#kubectl create -f sgw-load-balancer.yaml -n cb-server


