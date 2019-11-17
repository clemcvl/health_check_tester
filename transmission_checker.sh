#!/bin/bash

container_name="mytransmissionchecker"
logfile="/tmp/transmisison_checker.txt"

#Wait for transmission container to be up
wait_for_transmission () {
	while true; do
    		NOW=$(date +"%m-%d-%Y %H:%M:%S")
    		echo "$NOW - waiting for transmission" >> $2
		docker ps |grep $1
		if [ $? -eq 0 ]; then
			sleep 2
			break
		fi
		sleep 1
	done
}

wait_for_transmission $container_name $logfile



while true; do
#inspect container health
status=`docker inspect $container_name | jq ".[].State.Health.Status"`
echo "$NOW - DEBUG - status: $status ." >> $logfile
if [[ $status == *"unhealthy"* ]]; then
    NOW=$(date +"%m-%d-%Y %H:%M:%S")
    echo "$NOW - transmission unhealthy, stopping" >> $logfile
    #kill container if unhealthy
    docker stop $container_name
    sleep 5
    wait_for_transmission $container_name $logfile
    #exit 1
else
    NOW=$(date +"%m-%d-%Y %H:%M:%S")
    echo "$NOW - transission healthy" >> $logfile
fi
sleep 3

done
