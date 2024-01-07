#############################################################################################################################################
## Script utilities for Domoticz
## Date: 08-05-2016 # Version 1.0 # @julioalonso.es
## Configuration file:
##	bashcfg.json (JSON file must be located is same directory as script that use the function)
## Function:
##	writeLog ( [message] ) # Write message to log file
##  	getPassword ( [path_to_crypt_key],[variable_name] ) # Get variable password from configuration file and encrypt if not encrypted in file.
##	getVariable ( [variable_name] ) # Get variable from configuration file
#############################################################################################################################################

# Global variables
logFile="/var/log/domoticz/bashScript.log"
configurationFile="$SCRIPTPATH/bashcfg.json"


# Functions
writeLog() {
    if [ -f "$logFile" ]; then
        fileSize=$(du ${logFile} | sed 's/\([0-9]*\)\(.*\)/\1/')
        #echo "Tamaño de fichero de LOG: ${fileSize}kb"
        if [ $fileSize -gt 10240 ]; then
            mv $logFile "${logFile}.bck"
            echo "`date`: $1"  >> $logFile
            #logger "bash_script: ${1}"
        else
            echo "`date`: $1"  >> $logFile
            #logger "bash_script: ${1}"
        fi
    else
        echo "`date`: $1"  >> $logFile
        #logger "bash_script: ${1}"
    fi
    }
    
getPassword() {
	SCRIPT=$(readlink -f $0)
	SCRIPTPATH=`dirname $SCRIPT`
	local jsonPwd=$(cat $configurationFile | jq -r ".variables.$2")
	if [[ $jsonPwd =~ "crypted:" ]] ; then
		#echo "Crypted"
		local passwordCrypted=${jsonPwd/crypted:/}
		local passwordDecrypted=$(echo $passwordCrypted |openssl enc -base64 -d -A |openssl rsautl -decrypt -inkey $1)
		echo $passwordDecrypted
		
	else
		#echo "No Crypted"
		echo $jsonPwd
		local passwordCrypted=$(echo $jsonPwd |openssl rsautl -encrypt -inkey $1 |openssl enc -base64 -A)
		local newjsonPwd="crypted:$passwordCrypted"
		cat $configurationFile | jq ".variables.$2=\"$newjsonPwd\"" > "$configurationFile.tmp"
		mv "$configurationFile.tmp" $configurationFile	
	fi
	}
	
getVariable() {
	SCRIPT=$(readlink -f $0)
	SCRIPTPATH=`dirname $SCRIPT`
	local jsonVar=$(cat $configurationFile | jq -r ".variables.$1")
	echo $jsonVar
	}
