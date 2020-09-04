#!/bin/bash -l

#----------------------------------------
#        load ENV variables
#----------------------------------------
CFGFILE="facs.cfg"
source $CFGFILE

#----------------------------------------
#     Cloning FACS application
#----------------------------------------
git clone -b $REPO_BRANCH $FACS_GITHUB_REPO
rm -rf $PWD/facs/covid_data
FACS_LOCATION=$PWD/facs


#----------------------------------------
#     install required packages
#----------------------------------------
bash scripts/install_packages.sh


#----------------------------------------
#     Download config files from CKAN
#----------------------------------------
bash scripts/ckan_downloader.sh



#----------------------------------------
#     Add FACS to PYTHONPATH
#----------------------------------------
cat << EOF_CFGFILE >> $CFGFILE
export PYTHONPATH=$PWD/facs:\$PYTHONPATH
EOF_CFGFILE

source $CFGFILE


#----------------------------------------
#     RUN job
#----------------------------------------
LOG_RUN_JOB='run_job.log'
echo "PYTHONPATH = " $PYTHONPATH > $LOG_RUN_JOB

cd $LOCATION_NAME

# run a single run
echo "ENSEMBLE_MODE is disabled . . ." | tee -a "$LOG_RUN_JOB"
start_time="$(date -u +%s.%N)"
python3 $FACS_LOCATION/run.py --location=$LOCATION_NAME --ci_multiplier=$CI_MULTIPLIER --transition_scenario=$TRANSITION_SCENARIO --transition_mode=$TRANSITION_MODE --output_dir=$OUTPUT_DIR
end_time="$(date -u +%s.%N)"
elapsed="$(bc <<<"$end_time-$start_time")"
echo "Total Executing Time = $elapsed seconds" | tee -a "$LOG_RUN_JOB"


cd ..


#----------------------------------------
#     Zip output results 
#----------------------------------------

result_file_name=$LOCATION_NAME'-results-'$ID'-'$(whoami)

cat << EOF_CFGFILE >> $CFGFILE
RESULT_FILE_NAME=$result_file_name
EOF_CFGFILE

source facs.cfg

env > env.log
/usr/bin/env > env2.log

zip -r $result_file_name *.err *.out *.script *.yaml $LOCATION_NAME



#----------------------------------------
#      Upload results to CKAN
#----------------------------------------
bash scripts/ckan_uploader.sh