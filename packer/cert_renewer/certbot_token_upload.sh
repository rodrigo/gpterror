#!/bin/bash
echo $CERTBOT_VALIDATION > $CERTBOT_TOKEN
aws s3api put-object --bucket rebelatto --key certs/.well-known/acme-challenge/$CERTBOT_TOKEN --body $CERTBOT_TOKEN
