#!/bin/bash
sudo certbot certonly --manual --manual-auth-hook=/tmp/certbot_token_upload.sh \
  --work-dir=/var/lib/letsencrypt --no-eff-email -m rrebelatto@outlook.com \
  -d www.gpterror.online --agree-tos --force-renew -n
sudo chown -R ec2-user /etc/letsencrypt
