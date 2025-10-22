#!/bin/bash
# Generate Serial if not exist
#
if [ ! -f /opt/domoticz/userdata/config/.domoniqueserial ]
        then
                echo "dmn"`date +%y`"r20"`date +%m%d`$RANDOM > /opt/domoticz/userdata/config/.domoniqueserial
fi
cloudid=$(head -n 1 /opt/domoticz/userdata/config/.domoniqueserial | tr '[:lower:]' '[:upper:]')

# Update packages to install
apt-get update

# Required apt packages for implemetations:
#       - alexa-remote-control: jq oathtool
#
apt-get install -y jq oathtool

# Adding custom menu from ./config/templates
#
cp -v /opt/domoticz/userdata/config/templates/* /opt/domoticz/www/templates/

sed -i "s|<button class=\"btn\">.*</button>|<button class=\"btn\">$cloudid</button>|" "/opt/domoticz/www/templates/domonique cloud.html"
