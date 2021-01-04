#!/bin/bash
clear
port_forward=`ps -ef | grep 8091| grep -v grep| awk '{print $2}'`
kill -9 ${port_forward}

ns=`(kubectl get ns| awk '{print $1}' | egrep -v "default|NAME|docker|kube-node-lease|kube-public|kube-system|kubernetes-dashboard")`
echo "Choose one  NameSpace to Delete:"
echo ${ns}
echo " "
#echo "Enter Cluster NameSpace"
read cluster
kubectl delete ns ${cluster}

echo ''
#echo "Enter DAC Namespace"
#read dac
#kubectl delete ns ${dac}

echo ''
./operator_2.0/bin/cbopcfg | kubectl delete -f -
kubectl delete -f operator_2.0/crd.yaml
kubectl delete svc openldap
kubectl delete pod openldap
