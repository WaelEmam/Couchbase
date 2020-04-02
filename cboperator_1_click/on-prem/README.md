# List of Options available
* Just CB Cluster with some data.
* Data migration from Mysql.
* Data migration from MongoDB.
* Data migration from Mysql \& MongoDB.

## with Ldap integration run:
```bash
bash create_cluster_ldap.sh
```

## If no Ldap integration is needed, run:
```bash
bash create_cluster_no_ldap.sh
```
## Once env. is up and running:
* Load nifi templates (in templates folder) to nifi (depending on which env. you chose).
* Fix IPs and passwords in connectors.
* Start the flow.
