#!/bin/bash
kubectl delete deployments. zookeeper
kubectl delete svc kafka zookeeper connect mysql
kubectl delete pod kafka
kubectl delete pod connect mysql
