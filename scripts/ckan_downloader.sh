#!/bin/bash -l


#----------------------------------------
#        load ENV variables
#----------------------------------------
CFGFILE="facs.cfg"
source $CFGFILE

#----------------------------------------
#     check CNAK repo ENV variable
#----------------------------------------
if [ -z $CKANREPO ]
then
    echo "no CKANREPO specified !!!"
    exit 1
else
    echo USING $CKANREPO
fi

#----------------------------------------
#     create inputs folder
#----------------------------------------
if [ -d inputs ]; then
  rm -rf inputs
fi
mkdir -p inputs

#----------------------------------------
#     downloading input files from CKAN
#     based on INPUT_CONFIG_TAGS ENV variable
#----------------------------------------
DATASET=$(ckanapi action package_search fq=$INPUT_CONFIG_TAGS -r $CKANREPO | ./jq-linux64 -r .results[].name)
echo $DATASET

if [ -z "$DATASET" ]
then
    echo "There is no dataset with name input tag names : $INPUT_CONFIG_TAGS"
    exit 1
else
    echo "Found Datasets: $DATASET, Downloading resources"
fi

for i in $(ckanapi action package_show id=$DATASET -r $CKANREPO | ./jq-linux64 -r .resources[].url)
do
    echo $i
    wget $i -P inputs
done
echo "Downloading Input files from CKAN: DONE"


#----------------------------------------
#     check user input config and exact it
#----------------------------------------
INPUT_FILES=$(find inputs -name "$LOCATION_NAME*" -type f)

if [ -z "$INPUT_FILES" ]; then
    echo "there is not input config file name matching $LOCATION_NAME"
    exit 1
fi

#----------------------------------------
#   create a RUN folder and 
#   extract input config file there
#----------------------------------------
if [ -d RUNS ]; then
  rm -rf RUNS
fi
mkdir -p RUNS

for FILE in $INPUT_FILES;
do
    echo $FILE
    unzip $FILE -d RUNS

    # if ENSEMBLE_NUMBER>1, means we should have ensemble jobs
    if [ $ENSEMBLE_NUMBER -gt 1 ]; then
        for i in $(seq 1 $(($ENSEMBLE_NUMBER)))
        do
            mkdir RUNS/$LOCATION_NAME"_"$i
            cp -r RUNS/$LOCATION_NAME/* RUNS/$LOCATION_NAME"_"$i
        done
        rm -rf RUNS/$LOCATION_NAME
    fi

done



