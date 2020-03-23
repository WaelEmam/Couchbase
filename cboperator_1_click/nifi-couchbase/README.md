# My Environment
- MacOS Catalina
- Docker
- Kubernetes

## To Create the environment run
``` bash
bash create_env.sh
```

### This will create
- MySQL instance and load a sample dataset.
- Nifi instance, expose its port (8080) and load mysql connector to it.
- CB cluster that has 2 data nodes, 1 query node and 1 FTS,Analytics,Eventing node.
- Create some buckets.

### Once environment is up, :
- load MySQL-to-CB-2.xml template to nifi.
- fix IPs and passwords in connectors.
- start the flow
