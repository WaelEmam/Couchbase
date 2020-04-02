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
		bash ./cb_no_ldap.sh
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
		bash ./cb_no_ldap.sh

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
		bash ./cb_no_ldap.sh
            ;;
        5)
            break
            ;;
        *) echo "invalid option";;
    esac

