#!/usr/bin/env sh

set -e

pkg install -y jq base64 py311-cryptography

PUB_KEY=$(curl http://169.254.169.254/openstack/2018-08-27/meta_data.json | jq -r '.public_keys.[]')
PUB_KEY_ENDED=$(echo "$PUB_KEY" | base64 -e | tr -d \\n)

PASS=$(openssl rand -hex 32)

# Set OPNSense user password
echo "Setting public key for opnsense user"
echo "$PUB_KEY"
sed -i '' 's|<authorizedkeys>autochangeme_authorizedkeys==</authorizedkeys>|<authorizedkeys>'"${PUB_KEY_ENDED}"'</authorizedkeys>|g' /conf/config.xml

# TODO(vinetos): Encode the password using the RSA key
# TODO(vinetos): Push the encoded password to meta-data server

printf 'y\n'"$PASS"'\ntest'"$PASS" | opnsense-shell password

opnsense-shell reload
