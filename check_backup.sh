#!/bin/bash
# Nagios Plugin Bash Script - check_backup.sh
# This script checks if backup has been run
#Check for missing parameters
if [[ -z "$1" ]] 
then
	echo "Missing parameters! Syntax: ./check_backup.sh directory"
	exit 3
fi

# check for age of latest file
backup=$(find ${1} -maxdepth 1 -type f | xargs ls -tr | tail -1)
time_now=`date +%s`
time_backup=`stat -c %Y ${backup}`
time_diff=$(( (time_now - time_backup) ))
SEC_IN_HOUR=3600
UNIT="hours"
age_in_hours=$(( (${time_diff} / ${SEC_IN_HOUR}) ))

message="latest backup ${backup} is ${age_in_hours} hours old"
if [[ ${age_in_hours} < 24 ]] 
then
	echo "OK, ${message}"
	exit 0
elif [[ ${age_in_hours} < 48 ]]
then
	echo "WARNING, ${message}"
	exit 1
else
	echo "CRITICAL, ${message}"
	exit 2
fi
