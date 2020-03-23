# My Environment
- MacOS Catalina
- Docker
- Kubernetes

## CB cluster with LDAP integration
if you want to create a cluster that is integrated with LDAP to check out the RBAC featrues in CB, please run
```bash
bash create_cluster_ldap.sh
```
### This will create
- CB cluster that has 2 data nodes, 1 query node and 1 FTS,Analytics,Eventing node
- Create some buckets
- Load data into the created buckets
- Create an OpenLDAP pod and populate it with a very small set of users and groups
- Integrate CB cluster with LDAP
- Map a LDAP user in CB

If LDAP integration is not required, please run
``` bash
bash create_cluster_no_ldap.sh
```
