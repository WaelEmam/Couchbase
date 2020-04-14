#!/bin/bash
clear
echo " "
echo "What would you like to demo today?"
echo " "
echo "
"	1\) Just CB Cluster"
"	2\) Data migration from Mysql"
"	3\) Data migration from MongoDB"
"	4\) Data migration from Mysql \& MongoDB"
"       5\) CouchMovies Demo"
"       6\) CouchMart Demo"
"	7\) Quit"
"

read options

echo " Do you want LDAP integration? (Y/N)"

read LDAP

case $LDAP in 
	N|n)

#read options
    case $options in
        1)
            echo "Building CB Cluster"
            bash ./cb_no_ldap.sh
	    ;;
        2)
            echo "Building env for MySQL migration"
	    echo " "
	    echo "Creating MySQL POD"
	    	# Create Mysql Pod
 	    	kubectl run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=admin123 --port=3306 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
	    	sleep 15
		kubectl expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306
	    	#MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
	    	MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
	    	kubectl cp data/mysqlsampledatabase.sql  ${MYSQL_POD}:/tmp/mysqlsampledatabase.sql
	    	kubectl exec ${MYSQL_POD} -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		echo " "
	    	# Create Nifi Pod
		echo "Creating Nifi POD"
	    	kubectl create -f nifi.yaml
	    	sleep 15
	    	kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
	    	#NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
	    	NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
	    	kubectl cp mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
	    	sleep 15
		echo " "
		bash ./cb_no_ldap.sh
            ;;
        3)
            echo "Building env for Mongodb migration"
	    	# Create MongoDB Pod
            echo " "
            echo "Creating MonngoDB POD"
		kubectl run mongodb --image=mongo:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mongodb", "subdomain": "example"}}'
		sleep 15
		kubectl expose pod mongodb --type=LoadBalancer --port=27017 --target-port=27017
		#MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
		#MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
		kubectl cp data/script.js  mongodb:/tmp/script.js
		kubectl cp data/generated.json mongodb:/tmp/generated.json
		kubectl exec mongodb -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"

		# Create Nifi Pod
            echo " "
            echo "Creating Nifi POD"
		kubectl create -f nifi.yaml
		sleep 15
		kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
		#NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
		NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
		kubectl cp data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
		sleep 15
		bash ./cb_no_ldap.sh

            ;;
        4)
            echo "Building env for MySQL & MongoDB migration"
	    	 # Create Mysql Pod
		 echo "Creating MySQL POD "
		 echo " "
		 kubectl run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=admin123 --port=3306 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
                 sleep 15
		 kubectl expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306
                 #MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
                 MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
                 kubectl cp data/mysqlsampledatabase.sql  ${MYSQL_POD}:/tmp/mysqlsampledatabase.sql
                 kubectl exec ${MYSQL_POD} -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		 echo " "

                # Create MongoDB Pod
		echo "Creating Mongodb POD "
                kubectl run mongodb --image=mongo:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mongodb", "subdomain": "example"}}'
                sleep 15
		kubectl expose pod mongodb --type=LoadBalancer --port=27017 --target-port=27017
                #MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
                #MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
                kubectl cp data/script.js  mongodb:/tmp/script.js
                kubectl cp data/generated.json mongodb:/tmp/generated.json
                kubectl exec mongodb -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"
		echo " "

                # Create Nifi Pod
		echo "Creating Nifi POD "
                kubectl create -f nifi.yaml
                sleep 15
                kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
                #NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
                NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
                kubectl cp data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
                sleep 15
		echo "Creating CB Cluster "
		echo " "
		bash ./cb_no_ldap.sh
            ;;
	5) 
		bash couchmovies/couchmovies.sh
	   ;;
	6)
                bash couchmart/couchmart.sh
           ;;
        7)
            break
            ;;
        *) echo "invalid option";;
    esac
	;;
Y|y)
	    case $options in
        1)
            echo "Building CB Cluster"
            bash ./cb_ldap.sh
	    ;;
        2)
            echo "Building env for MySQL migration"
	    echo " "
	    echo "Creating MySQL POD"
	    	# Create Mysql Pod
 	    	kubectl run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=admin123 --port=3306 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
	    	sleep 15
		kubectl expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306
	    	#MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
	    	MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
	    	kubectl cp data/mysqlsampledatabase.sql  ${MYSQL_POD}:/tmp/mysqlsampledatabase.sql
	    	kubectl exec ${MYSQL_POD} -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		echo " "
	    	# Create Nifi Pod
		echo "Creating Nifi POD"
	    	kubectl create -f nifi.yaml
	    	sleep 15
	    	kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
	    	#NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
	    	NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
	    	kubectl cp data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
	    	sleep 15
		echo " "
		bash ./cb_ldap.sh
            ;;
        3)
            echo "Building env for Mongodb migration"
	    	# Create MongoDB Pod
            echo " "
            echo "Creating MonngoDB POD"
		kubectl run mongodb --image=mongo:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mongodb", "subdomain": "example"}}'
		sleep 15
		kubectl expose pod mongodb --type=LoadBalancer --port=27017 --target-port=27017
		#MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
		#MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
		kubectl cp data/script.js  mongodb:/tmp/script.js
		kubectl cp data/generated.json mongodb:/tmp/generated.json
		kubectl exec mongodb -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"

		# Create Nifi Pod
            echo " "
            echo "Creating Nifi POD"
		kubectl create -f nifi.yaml
		sleep 15
		kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
		#NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
		NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
		kubectl cp data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
		sleep 15
		bash ./cb_ldap.sh

            ;;
        4)
            echo "Building env for MySQL & MongoDB migration"
	    	 # Create Mysql Pod
		 echo "Creating MySQL POD "
		 echo " "
		 kubectl run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=admin123 --port=3306 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
                 sleep 15
		 kubectl expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306
                 #MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
                 MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
                 kubectl cp data/mysqlsampledatabase.sql  ${MYSQL_POD}:/tmp/mysqlsampledatabase.sql
                 kubectl exec ${MYSQL_POD} -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		 echo " "

                # Create MongoDB Pod
		echo "Creating Mongodb POD "
                kubectl run mongodb --image=mongo:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mongodb", "subdomain": "example"}}'
                sleep 15
		kubectl expose pod mongodb --type=LoadBalancer --port=27017 --target-port=27017
                #MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
                #MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
                kubectl cp data/script.js  mongodb:/tmp/script.js
                kubectl cp data/generated.json mongodb:/tmp/generated.json
                kubectl exec mongodb -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"
		echo " "

                # Create Nifi Pod
		echo "Creating Nifi POD "
                kubectl create -f nifi.yaml
                sleep 15
                kubectl expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
                #NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
                NIFI_POD=`kubectl get pods | grep nifi | awk '{print $1}'`
                kubectl cp data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
                sleep 15
		echo "Creating CB Cluster "
		echo " "
		bash ./cb_ldap.sh
            ;;
	5)
                bash couchmovies/couchmovies.sh
           ;;
        6)
                bash couchmart/couchmart.sh
           ;;
        7)
            break
           ;;
        *) echo "invalid option";;
    esac

	;;
esac
