#!/bin/bash

if [ -z $DEMO_DIR ];then
	export DEMO_DIR=/travel-sample
fi

if [ -z $CB_SERVER ];then
	export CB_SERVER=127.0.0.1
fi

export CB_ENGINE=couchbase://$CB_SERVER

if [ -z $CB_USER ];then
	export CB_USER=Administrator
fi

if [ -z $CB_PASSWORD ];then
	export CB_PASSWORD=password
fi

if [ -z $CB_SYNC_GW ];then
	export CB_SYNC_GW=127.0.0.1
fi
