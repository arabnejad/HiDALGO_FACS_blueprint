#!/bin/bash -l

LOGFILE="pre_configuring_log.txt"


cat << EOF_LOGFILE > $LOGFILE
log pre_configuring.sh ...

facs_github_repo = $1
branch =  $2
location_name = $3
ci_multiplier = $4
transition_scenario = $5
transition_mode = $6
quick_test_flag = $7
output_dir = $8
ensemble_number = $9
jobmanager_type = ${10}
nnodes = ${11}
ncorespernode = ${12}
ckanrepo = ${13}
ckanapikey = ${14}
inputconfigtags = ${15}
EOF_LOGFILE


CFGFILE="facs.cfg"
id=`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1`
cat << EOF_CFGFILE > $CFGFILE
FACS_GITHUB_REPO=$1
REPO_BRANCH=$2
LOCATION_NAME=$3
CI_MULTIPLIER=$4
TRANSITION_SCENARIO=$5
TRANSITION_MODE=$6
QUICK_TEST_FLAG=$7
OUTPUT_DIR=$8
ENSEMBLE_NUMBER=$9
JOBMANAGER=${10}
NUMBER_OF_NODES=${11}
NUMBER_OF_CORES_PER_NODE=${12}
CKANREPO=${13}
CKANAPIKEY=${14}
INPUT_CONFIG_TAGS=${15}
ID=$id
CURDIR=$PWD
EOF_CFGFILE

source $CFGFILE

#----------------------------------------
#    Cloning HiDALGO FACS blueprint repo
#----------------------------------------
git clone https://github.com/arabnejad/HiDALGO_FACS_blueprint.git

mv HiDALGO_FACS_blueprint/scripts .
rm -rf HiDALGO_FACS_blueprint



