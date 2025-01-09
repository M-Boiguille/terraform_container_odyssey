#!/bin/bash

DROPLET_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

if [ -z "$DROPLET_IP" ]; then
	echo "Impossible de récupérer l'IP publique." | tee -a /opt/log
	exit 1
fi

sed -i "s/^DOMAIN_NAME=.*/DOMAIN_NAME=${DROPLET_IP}/" container-odyssey/srcs/.env
sed -i "s/server_name\s+localhost;/server_name ${DROPLET_IP};/" \
	container-odyssey/srcs/requirements/nginx/conf/nginx.conf

echo "L'adresse IP publique a été définie : $DROPLET_IP" | tee -a /opt/log
cat container-odyssey/srcs/.env >>/opt/log
cat container-odyssey/srcs/requirements/nginx/conf/nginx.conf >>/opt/log
