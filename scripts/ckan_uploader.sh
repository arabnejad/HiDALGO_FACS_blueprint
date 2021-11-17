#!/bin/bash -l


#----------------------------------------
#        load ENV variables
#----------------------------------------
CFGFILE="facs.cfg"
source $CFGFILE


#----------------------------------------
#      Upload results to CKAN
#----------------------------------------

if [ -z $CKANAPIKEY ]; then
    echo "No CKAN API key provided, don't uploading to CKAN"

else
    # Uploading to CKAN to Dataset $ID 
    ckanapi action resource_create package_id='facs-outputs' description="output results for $LOCATION_NAME location [ run id : $ID ][executed by $(whoami)] $(date +'[%H:%M:%S][%m/%d/%Y]') " name=$RESULT_FILE_NAME -r $CKANREPO -a $CKANAPIKEY upload@./$RESULT_FILE_NAME'.zip'
fi


