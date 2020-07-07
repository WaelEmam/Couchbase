#!/bin/bash
clear
echo " "
echo "What would you like to demo today?"
echo " "
echo "
"	1\) Just CB Cluster"
"	2\) Data migration from Mysql using Nifi"
"	3\) Data migration from MongoDB using Nifi"
"	4\) Data migration from Mysql \& MongoDB using Nifi"
"       5\) Data streaming from Mysql using Kafka connect" -- WIP
"       6\) CouchMovies Demo" -- WIP
"       7\) CouchMart Demo"
"	8\) Stocks Demo"
"	9\) Quit"
"

read options

echo " Do you want LDAP integration? (Y/N)"

read LDAP
echo "Enter you Namespace name"
read ns
#kubectl create ns ${ns}
echo "Enter Couchbase Cluster Name"
read cluster
export ns
export cluster
case $LDAP in 
	N|n)

#read options
    case $options in
        1)
            echo "Building CB Cluster"
            bash ./cb_no_ldap.sh ${ns} ${cluster}
	    ;;
        2)
            echo "Building env for MySQL migration"
	    echo " "
	    echo "Creating MySQL POD"
	    	# Create Mysql Pod
 	    	kubectl -n ${ns} run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=admin123 --port=3306 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
	    	sleep 15
		kubectl -n ${ns} expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306
	    	#MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
	    	kubectl -n ${ns} cp ../data/mysqlsampledatabase.sql  mysql:/tmp/mysqlsampledatabase.sql
	    	kubectl -n ${ns} exec mysql -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		echo " "
	    	# Create Nifi Pod
		echo "Creating Nifi POD"
	    	kubectl -n ${ns} create -f ../nifi.yaml
	    	sleep 15
	    	kubectl -n ${ns} expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
	    	NIFI_POD=`kubectl -n ${ns} get pods | grep nifi | awk '{print $1}'`
	    	kubectl -n ${ns} cp ../mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
	    	sleep 15
		echo " "
		bash ./cb_no_ldap.sh
            ;;
        3)
            echo "Building env for Mongodb migration"
	    	# Create MongoDB Pod
            echo " "
            echo "Creating MonngoDB POD"
		kubectl -n ${ns} run mongodb --image=mongo:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mongodb", "subdomain": "example"}}'
		sleep 15
		kubectl -n ${ns} expose pod mongodb --type=LoadBalancer --port=27017 --target-port=27017
		kubectl -n ${ns} cp data/script.js  mongodb:/tmp/script.js
		kubectl -n ${ns} cp data/generated.json mongodb:/tmp/generated.json
		kubectl -n ${ns} exec mongodb -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"

		# Create Nifi Pod
            echo " "
            echo "Creating Nifi POD"
		kubectl -n ${ns} create -f nifi.yaml
		sleep 15
		kubectl -n ${ns} expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
		NIFI_POD=`kubectl -n ${ns} get pods | grep nifi | awk '{print $1}'`
		kubectl -n ${ns} cp ../data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
		sleep 15
		bash ./cb_no_ldap.sh

            ;;
        4)
            echo "Building env for MySQL & MongoDB migration"
	    	 # Create Mysql Pod
		 echo "Creating MySQL POD "
		 echo " "
		 kubectl -n ${ns} run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=admin123 --port=3306 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
                 sleep 15
		 kubectl -n ${ns} expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306
                 #MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
                 #MYSQL_POD=`kubectl get pods -o wide| grep mysql | awk '{print $1}'`
                 kubectl -n ${ns} cp ../data/mysqlsampledatabase.sql  mysql:/tmp/mysqlsampledatabase.sql
                 kubectl -n ${ns} exec mysql -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		 echo " "

                # Create MongoDB Pod
		echo "Creating Mongodb POD "
                kubectl -n ${ns} run mongodb --image=mongo:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mongodb", "subdomain": "example"}}'
                sleep 15
		kubectl -n ${ns} expose pod mongodb --type=LoadBalancer --port=27017 --target-port=27017
                kubectl -n ${ns} cp ../data/script.js  mongodb:/tmp/script.js
                kubectl -n ${ns} cp ../data/generated.json mongodb:/tmp/generated.json
                kubectl -n ${ns} exec mongodb -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"
		echo " "

                # Create Nifi Pod
		echo "Creating Nifi POD "
                kubectl -n ${ns} create -f nifi.yaml
                sleep 15
                kubectl -n ${ns} expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
                #NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
                NIFI_POD=`kubectl -n ${ns} get pods | grep nifi | awk '{print $1}'`
                kubectl -n ${ns} cp ../data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
                sleep 15
		echo "Creating CB Cluster "
		echo " "
		bash ./cb_no_ldap.sh
            ;;
        5)
		bash mysql-kafka-cb/create_env.sh
	    ;;
	6) 
		bash couchmovies/couchmovies.sh
	   ;;
	7)
                bash couchmart_no_ldap.sh
           ;;
	8)
		bash stock-ex/create_env.sh
	  ;;
        9)
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
 	    	kubectl -n ${ns} run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=admin123 --port=3306 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
	    	sleep 15
		kubectl -n ${ns} expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306
	    	#MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
	    	MYSQL_POD=`kubectl -n ${ns} get pods -o wide| grep mysql | awk '{print $1}'`
	    	kubectl -n ${ns} cp ../data/mysqlsampledatabase.sql  ${MYSQL_POD}:/tmp/mysqlsampledatabase.sql
	    	kubectl -n ${ns} exec ${MYSQL_POD} -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		echo " "
	    	# Create Nifi Pod
		echo "Creating Nifi POD"
	    	kubectl -n ${ns} create -f nifi.yaml
	    	sleep 15
	    	kubectl -n ${ns} expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
	    	#NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
	    	NIFI_POD=`kubectl -n ${ns} get pods | grep nifi | awk '{print $1}'`
	    	kubectl cp ../data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
	    	sleep 15
		echo " "
		bash ./cb_ldap.sh
            ;;
        3)
            echo "Building env for Mongodb migration"
	    	# Create MongoDB Pod
            echo " "
            echo "Creating MonngoDB POD"
		kubectl -n ${ns} run mongodb --image=mongo:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mongodb", "subdomain": "example"}}'
		sleep 15
		kubectl -n ${ns} expose pod mongodb --type=LoadBalancer --port=27017 --target-port=27017
		#MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
		#MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
		kubectl -n ${ns} cp ../data/script.js  mongodb:/tmp/script.js
		kubectl -n ${ns} cp ../data/generated.json mongodb:/tmp/generated.json
		kubectl -n ${ns} exec mongodb -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"

		# Create Nifi Pod
            echo " "
            echo "Creating Nifi POD"
		kubectl -n ${ns} create -f nifi.yaml
		sleep 15
		kubectl -n ${ns} expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
		#NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
		NIFI_POD=`kubectl -n ${ns} get pods | grep nifi | awk '{print $1}'`
		kubectl -n ${ns} cp ../data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
		sleep 15
		bash ./cb_ldap.sh

            ;;
        4)
            echo "Building env for MySQL & MongoDB migration"
	    	 # Create Mysql Pod
		 echo "Creating MySQL POD "
		 echo " "
		 kubectl -n ${ns} run mysql --image=mysql:latest --restart=Never --env MYSQL_ROOT_PASSWORD=admin123 --port=3306 --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mysql", "subdomain": "example"}}'
                 sleep 15
		 kubectl -n ${ns} expose pod  mysql --type=LoadBalancer --port=3306 --target-port=3306
                 #MYSQL_IP=`kubectl get pods -o wide| grep mysql | awk '{print $6}'`
                 MYSQL_POD=`kubectl -n ${ns} get pods -o wide| grep mysql | awk '{print $1}'`
                 kubectl -n ${ns} cp ../data/mysqlsampledatabase.sql  ${MYSQL_POD}:/tmp/mysqlsampledatabase.sql
                 kubectl -n ${ns} exec ${MYSQL_POD} -- bash -c "cd /tmp/; mysql -uroot -padmin123 < mysqlsampledatabase.sql"
		 echo " "

                # Create MongoDB Pod
		echo "Creating Mongodb POD "
                kubectl -n ${ns} run mongodb --image=mongo:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"hostname": "mongodb", "subdomain": "example"}}'
                sleep 15
		kubectl -n ${ns} expose pod mongodb --type=LoadBalancer --port=27017 --target-port=27017
                #MONGO_IP=`kubectl get pods -o wide| grep mongo | awk '{print $6}'`
                #MONGO_POD=`kubectl get pods -o wide| grep mongo | awk '{print $1}'`
                kubectl -n ${ns} cp ../data/script.js  mongodb:/tmp/script.js
                kubectl -n ${ns} cp ../data/generated.json mongodb:/tmp/generated.json
                kubectl -n ${ns} exec mongodb -- bash -c "mongo /tmp/script.js; mongoimport -c cases --jsonArray --drop --file /tmp/generated.json"
		echo " "

                # Create Nifi Pod
		echo "Creating Nifi POD "
                kubectl -n ${ns} create -f nifi.yaml
                sleep 15
                kubectl -n ${ns} expose deployment nifi --type=LoadBalancer --port=8080 --target-port=8080
                #NIFI_IP=`kubectl get pods -o wide| grep nifi | awk '{print $6}'`
                NIFI_POD=`kubectl -n ${ns} get pods | grep nifi | awk '{print $1}'`
                kubectl -n ${ns} cp ../data/mysql-connector-java-8.0.19.jar ${NIFI_POD}:/tmp
                sleep 15
		echo "Creating CB Cluster "
		echo " "
		bash ./cb_ldap.sh
            ;;
	5)
                bash couchmovies/couchmovies.sh
           ;;
        6)
                bash couchmart_no_ldap.sh
           ;;
        7)
            break
           ;;
        *) echo "invalid option";;
    esac

	;;
esac
