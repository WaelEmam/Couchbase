#!/bin/bash
kubectl delete deployments. zookeeper
kubectl delete svc kafka zookeeper
kubectl delete pod kafka
