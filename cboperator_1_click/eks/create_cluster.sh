#!/bin/bash

eksctl create cluster \
--name cb-on-eks \
--version 1.14 \
--region us-east-1 \
--zones us-east-1a,us-east-1b,us-east-1c \
--nodegroup-name standard-workers \
--node-type m5.xlarge \
--nodes 3 \
--nodes-min 3 \
--nodes-max 6 \
--node-ami auto \
--vpc-cidr 172.16.0.0/24

kubectl create -f namespace.yaml

# Create TLS Certificate
cd ../../easy-rsa/easyrsa3/
kubectl create secret generic couchbase-server-tls --from-file chain.pem --from-file pkey.key --namespace cb-eks
kubectl create secret generic couchbase-operator-tls --from-file pki/ca.crt --namespace cb-eks
kubectl create secret generic couchbase-operator-admission --from-file tls-cert-file --from-file tls-private-key-file --namespace cb-eks
kubectl get secret --namespace cb-eks

cd ../../cboperator_1_click/eks/

# Install Admission Controller
kubectl create -f admission-eks.yaml --namespace cb-eks

# Install CRD
kubectl create -f crd-eks.yaml --namespace cb-eks

# Create a Operator Role
kubectl create -f operator-role.yaml --namespace cb-eks

# Create Service Account
kubectl create serviceaccount couchbase-operator --namespace cb-eks
kubectl create rolebinding couchbase-operator --role couchbase-operator --serviceaccount cb-eks:couchbase-operator --namespace cb-eks


# Deploy Couchbase Operator
kubectl create -f operator-deployment.yaml --namespace cb-eks

# Verify
# kubectl get deployments --namespace cb-eks

# Create Secret for Couchbase Admin Console
kubectl create -f secret.yaml --namespace cb-eks

# Create storage class for the k8s cluster
kubectl create -f sc-gp2.yaml

kubectl get sc --namespace cb-eks

# Deploy Couchbase Cluster

kubectl create -f couchbase-cluster-eks.yaml -n cb-eks


