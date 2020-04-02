#!/bin/bash
clear
echo "What would you like to demo today?"
echo " "
echo "
"	1\) Just CB Cluster"
"	2\) Data migration from Mysql"
"	3\) Data migration from MongoDB"
"	4\) Data migration from Mysql \& MongoDB"
"	5\) Quit"
"

read options
    case $options in
        1)
            echo "Building CB Cluster"
	    break
            ;;
        2)
            echo "Building env for MySQL migration"
	    echo " "
	    	# Create Mysql Pod
 	    	kubectl run mysql --image=mysql:latest --env MYSQL_ROOT_PASSWORD=admin123 --port=3306
	    	sleep 15
	    	MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
	    	MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
	    	kubectl cp mysqlsampledatabase.sql  ${MYSQL_POD}:/tmp/mysqlsampledatabase.sql
	    	kubectl exec ${MYSQL_POD} -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		echo " "
	    	# Create Nifi Pod
	    	kubectl create -f nifi.yaml
	    	sleep 15
	    	kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
	    	NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
	    	NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
	    	kubectl cp mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
	    	sleep 15
		echo " "
		bash ./cb_ldap.sh
            ;;
        3)
            echo "Building env for Mongodb migration"
	    	# Create MongoDB Pod
		kubectl run mongodb --image=mongo:latest
		sleep 15

		#MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
		MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
		kubectl cp script.js  ${MONGO_POD}:/tmp/script.js
		kubectl cp generated.json ${MONGO_POD}:/tmp/generated.json
		kubectl exec ${MONGO_POD} -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"

		# Create Nifi Pod
		kubectl create -f nifi.yaml
		sleep 15
		kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
		NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
		NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
		kubectl cp mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
		sleep 15
		bash ./cb_ldap.sh

            ;;
        4)
            echo "Building env for MySQL & MongoDB migration"
	    	 # Create Mysql Pod
		 echo "Creating MySQL POD "
		 echo " "
                 kubectl run mysql --image=mysql:latest --env MYSQL_ROOT_PASSWORD=admin123 --port=3306
                 sleep 15
                 MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
                 MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
                 kubectl cp mysqlsampledatabase.sql  ${MYSQL_POD}:/tmp/mysqlsampledatabase.sql
                 kubectl exec ${MYSQL_POD} -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		 echo " "

                # Create MongoDB Pod
		echo "Creating Mongodb POD "
                kubectl run mongodb --image=mongo:latest
                sleep 15

                #MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
                MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
                kubectl cp script.js  ${MONGO_POD}:/tmp/script.js
                kubectl cp generated.json ${MONGO_POD}:/tmp/generated.json
                kubectl exec ${MONGO_POD} -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"
		echo " "

                # Create Nifi Pod
		echo "Creating Nifi POD "
                kubectl create -f nifi.yaml
                sleep 15
                kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
                NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
                NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
                kubectl cp mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
                sleep 15
		echo "Creating CB Cluster "
		echo " "
		bash ./cb_ldap.sh
            ;;
        5)
            break
            ;;
        *) echo "invalid option";;
    esac

# Create CB Cluster

#kubectl create -f admission.yaml
#kubectl create -f crd.yaml
#kubectl create -f operator-role.yaml --namespace default
#kubectl create -f operator-service-account.yaml --namespace default
#kubectl create -f operator-role-binding.yaml --namespace default
#kubectl create -f operator-deployment.yaml --namespace default
#kubectl create -f secret.yaml
#kubectl create -f couchbase-cluster.yaml

# Wait till all pods are up and running
#echo "Waiting for Pods to start"
#sleep 120
#kubectl port-forward wael-cb-k8s-0000 8091:8091 &


# Copy Ecomm Data Set (50 Users, 100 Products, 60 Orders, 30 Reviews)
#kubectl cp data/ecomm wael-cb-k8s-0000:/tmp/ecomm

# Copy Music Data Set (10 Countries, 50 Users, 50 Tracks, 50 Playlists)
#kubectl cp data/music wael-cb-k8s-0000:/tmp/music

# Copy Contacts Data Set (50 Contacts)
#kubectl cp data/contacts wael-cb-k8s-0000:/tmp/contacts

# Import Data set to ecommerce bucket
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/reviews.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/users.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/products.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b ecommerce -f list -d file:///tmp/ecomm/orders.json -g key::%_id% -t 4"

# Import Music Data Set
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/countries.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/users.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/tracks.json -g key::%_id% -t 4"
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b music -f list -d file:///tmp/music/playlists.json -g key::%_id% -t 4"


# Import Contacts Dataset
#kubectl exec wael-cb-k8s-0000 -- bash -c "cbimport json -c couchbase://localhost -u Administrator -p password -b contacts -f list -d file:///tmp/contacts/contacts.json -g key::%contact_id% -t 4"

# LDAP Integration

#kubectl run openldap --image=osixia/openldap:1.3.0 --port=389 --env LDAP_ORGANISATION="Couchbase" --env LDAP_DOMAIN="wael.couchbase.com" --env LDAP_ADMIN_PASSWORD="admin123"
#kubectl expose deployment openldap --type=LoadBalancer --port=389 --target-port=389
#sleep 40
#ldapadd -x -H ldap://localhost:389 -D "cn=admin,dc=wael,dc=couchbase,dc=com" -w admin123 -f output_all.ldif
#ldapadd -x -H ldap://localhost:389 -D "cn=admin,dc=wael,dc=couchbase,dc=com" -w admin123 -f ldap.ldif
#ldap=`kubectl get pods -o wide | grep open| awk '{print $6}'`


#/Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=wael,dc=couchbase,dc=com' --bind-password 'admin123' --authentication-enabled 1 --user-dn-query 'ou=users,dc=wael,dc=couchbase,dc=com??one?(uid=%u)' --authorization-enabled 1 --group-query 'ou=groups,dc=wael,dc=couchbase,dc=com??one?(member=%D)'
# /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli setting-ldap --cluster http://localhost --username Administrator --password password --hosts ${ldap} --port 389 --bind-dn 'cn=admin,dc=wael,dc=couchbase,dc=com' --bind-password 'admin123' --authentication-enabled 1

# Set Users Permissions
#kubectl exec wael-cb-k8s-0000 -- bash -c "couchbase-cli user-manage -c 127.0.0.1:8091 -u Administrator -p password --set --rbac-username erwin  --rbac-name "Erwin" --roles bucket_admin[music],data_writer[music],fts_admin[music],query_manage_index[music],query_delete[music],query_insert[music],query_select[music],query_update[music]  --auth-domain external"

