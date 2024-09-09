#!/bin/sh
# This script is an rc script based on the one from Remy van Elst.

# Copyright (C) 2018 Remy van Elst.
# Author: Remy van Elst for https://www.cloudvps.com
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

# This script sets the root password
# to a random password generated on the instance
# and posts that if possible to the openstack
# metadata service for nova get-password.

# PROVIDE: firstboot
# REQUIRE: LOGIN DAEMON NETWORKING
# KEYWORD: nojail

. /etc/rc.subr

name=firstboot
rcvar=firstboot_enable

start_cmd="${name}_start"

firstboot_start() {

  logger "Started set root password and post to metadata service"

  if [ -e "/var/lib/cloud/instance/rootpassword-random" ]; then
    logger "Password has already been set."
    # script already ran on this instance.
    # /var/lib/cloud/instance/ is a symlink to /var/lib/cloud/instances/$instance_uuid
    # if user creates an image and deploys image, this must run again, that file will not exist
    exit 0
  fi

  export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/root/bin

  # Two tmp files for the SSH and SSL pubkey
  SSH_KEYFILE=$(mktemp)
  SSL_KEYFILE=$(mktemp)

  # get the ssh public key from the metadata server.
  curl -s -f http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key >$SSH_KEYFILE
  if [ $? != 0 ]; then
    logger "Instance public SSH key not found on metadata service. Unable to set password"
    exit 0
  fi

  # NOTE(vinetos): OPNsense specific addition of public key for ssh connection
  PUB_KEY_ENCODED=$(cat "$SSH_KEYFILE" | base64 | tr -d \\n)
  sed -i '' 's|<authorizedkeys>autochangeme_authorizedkeys==</authorizedkeys>|<authorizedkeys>'"${PUB_KEY_ENCODED}"'</authorizedkeys>|g' /conf/config.xml

  # generate a random password
  # our images have have ged installed so should have enough entropy at boot.
  RANDOM_PASSWORD="$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -c 30)"
  if [ -z ${RANDOM_PASSWORD} ]; then
    logger "unable to generate random password."
    exit 0
  fi

  # set the root password to this random password
  # add any other password changes like admin for DirectAdmin.
  # NOTE(vinetos): OPNsense specific password change
  printf 'y\n'"$RANDOM_PASSWORD"'\n'"$RANDOM_PASSWORD" | opnsense-shell password

  if [ -s "$SSH_KEYFILE" ]; then
    # convert the ssh pubkey to an SSL keyfile so that we can use it to encrypt with OpenSSL
    ssh-keygen -e -f $SSH_KEYFILE -m PKCS8 >$SSL_KEYFILE
    ENCRYPTED=$(echo "$RANDOM_PASSWORD" | openssl rsautl -encrypt -pubin -inkey $SSL_KEYFILE -keyform PEM | openssl base64 -e -A)
    # post encrypted blob to metadata service. Must return true otherwise instance might fail to boot.
    curl -s -X POST http://169.254.169.254/openstack/2013-04-04/password -d $ENCRYPTED 2>&1 >/dev/null || true
  fi
  # housekeeping
  rm -rf $SSH_KEYFILE $SSL_KEYFILE

  # Make sure the script wont be run again by error
  mkdir -p /var/lib/cloud/instance/
  touch /var/lib/cloud/instance/rootpassword-random
  sysrc firstboot_enable="FALSE"

  #sync the hard disk
  sync

  #sleep to make sure everything is done
  sleep 1

  # Clean up history file
  rm /root/.history

  # NOTE(vinetos): Reload OPNsense to apply our modifications
  opnsense-shell reload
}

load_rc_config $name
run_rc_command "$1"
