#!/bin/bash
## Step1: Generate Serial if not exist
if [ ! -f /opt/domoticz/userdata/config/.domoniqueserial ]
        then
                echo "dmn"`date +%y`"r20"`date +%m%d`$RANDOM > /opt/domoticz/userdata/config/.domoniqueserial
fi
cloudid=$(head -n 1 /opt/domoticz/userdata/config/.domoniqueserial | tr '[:lower:]' '[:upper:]')
## Step1: End

## Step2: Install required packages for implemetations:
apt-get update
# 1) alexa-remote-control: jq oathtool
apt-get install -y jq oathtool
# 2) GPIO Control Plugin: python3-libgpiod
apt-get install -y python3-libgpiod
# 3) nut-upsd plugin: 
python3 -m pip install --no-input telnetlib3
## Step2: End

## Step3: Adding custom menu from ./config/templates
cp -v /opt/domoticz/userdata/config/templates/* /opt/domoticz/www/templates/
## Step3: End

## Step4: Installing MachineOn theme
if [ ! -d "/opt/domoticz/www/styles/machinon" ]; then
    git clone -b dist --single-branch https://github.com/domoticz/Machinon.git /opt/domoticz/www/styles/machinon
else
    echo "MachineOn theme already installed."
fi
## Step4: End

sed -i "s|<button class=\"btn\">.*</button>|<button class=\"btn\">$cloudid</button>|" "/opt/domoticz/www/templates/domonique cloud.html"
