#!/bin/bash
# Nagios Plugin Bash Script - check_backup.sh
# This script checks if backup has been run
#Check for missing parameters
if [[ -z "$1" ]] 
then
	echo "Missing parameters! Syntax: ./check_bitcoin.sh rpcuser rpcpass network"
	exit 3
fi

rpcuser=${1}
rpcpass=${2}
network=${3}

MAINNET_PORT=8332
TESTNET_PORT=18332

if [[ "${network}" = "testnet" ]]
then
	PORT=${TESTNET_PORT}
elif [[ "${network}" = "" ]]
then
	PORT=${MAINNET_PORT}
else
	echo "Unknown network: ${network}"
	exit 3
fi

# check for remote blockheight
remote_blockheight=`curl -L https://blockstream.info/${network}/api/blocks/tip/height`
local_blockheight=`curl --data-binary '{"jsonrpc":"1.0","id":"curltext","method":"getblockcount","params":[]}' -H 'content-type:text/plain;' http://${rpcuser}:${rpcpass}@127.0.0.1:${PORT}/ | grep -o -E "\"result\":[0-9]+" | awk -F: '{print $2}'`

CRITICAL=6
WARNING=3

message="blockheight:: remote: ${remote_blockheight} local: ${local_blockheight}"
if [[ ${local_blockheight} -lt  $(( (${remote_blockheight} - ${CRITICAL} ) )) ]] 
then
	echo "CRITICAL, ${message}"
	exit 2
elif [[ ${local_blockheight} -lt  $(( (${remote_blockheight} - ${WARNING} ) )) ]]
then
	echo "WARNING, ${message}"
	exit 1
else
	echo "OK, ${message}"
	exit 
fi
