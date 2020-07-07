#!/bin/bash


curl -H "Accept:application/json" -H "Content-Type:application/json" -POST -d @./mysql-kafka-connector http://localhost:8083/connectors/
curl -H "Accept:application/json" -H "Content-Type:application/json" -POST -d @./kafka-cb-connector http://localhost:8083/connectors/
