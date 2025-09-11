#!/usr/bin/env bash

# Generate VAPID keys
openssl ecparam -name prime256v1 -genkey -noout -out vapid_private.pem
PRIVATE_KEY=$(base64 -i vapid_private.pem | tr -d '\n' | tr -d '=')
PUBLIC_KEY=$(openssl ec -in vapid_private.pem -outform DER | tail --bytes 65 | base64 | tr '/+' '_-' | tr -d '\n' | tr -d '=')
rm vapid_private.pem
ENCRYPTION_KEY=$(openssl rand -base64 32)
echo "VAPID private_key:   $PRIVATE_KEY"
echo "VAPID public_key :   $PUBLIC_KEY"
echo "File encryption_key: $ENCRYPTION_KEY"
