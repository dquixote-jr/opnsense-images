#!/usr/bin/env sh

set -e

# Install Cloud-init
pkg install -y net/cloud-init

sysrc cloudinit_enable="YES"
