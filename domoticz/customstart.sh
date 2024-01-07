#!/bin/bash
# Generate Serial if not exist
#
if [ ! -f /opt/domoticz/userdata/config/.domoniqueserial ]
	then
		echo "dmn"`date +%y`"r20"`date +%m%d`s$RANDOM > /opt/domoticz/userdata/config/.domoniqueserial
fi

# Update packages to install
apt-get update

# Required apt packages for implemetations:
# 	- alexa-remote-control: jq oathtool
#
apt-get install -y jq oathtool

# Adding custom menu from ./config/templates
#
cp -v /opt/domoticz/userdata/config/templates/* /opt/domoticz/www/templates/
