#!/bin/bash

kubectl run openldap --image=osixia/openldap:1.3.0 --port=389 --env LDAP_ORGANISATION="Couchbase" --env LDAP_DOMAIN="wael.couchbase.com" --env LDAP_ADMIN_PASSWORD="admin123"
kubectl expose deployment openldap --type=LoadBalancer --port=389 --target-port=389
sleep 40
ldapadd -x -H ldap://localhost:389 -D "cn=admin,dc=wael,dc=couchbase,dc=com" -w admin123 -f output.ldif
