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
* load nifi templates (in templates folder) to nifi (depending on which env. you chose).
* fix IPs and passwords in connectors.
* start the flow
