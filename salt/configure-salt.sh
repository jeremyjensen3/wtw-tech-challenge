#!/bin/bash

#Install Salt
curl -L https://bootstrap.saltstack.com -o bootstrap_salt.sh
sh bootstrap_salt.sh

#Set minion config file to use local instead of remote
sed -i '/#file_client: remote/c file_client: local' /etc/salt/minion

#Copy Salt directories to proper location
mkdir -p /srv/salt
cp -r salt/srv/salt/* /srv/salt