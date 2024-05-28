#!/usr/bin/env sh

set -e

# Disable SSH password authentication
sed -i '' '/<passwordauth>1<\/passwordauth>/d' /conf/config.xml

shutdown -p now
