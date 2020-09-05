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



if [[ "${QUICK_TEST_FLAG^^}" == "TRUE" ]]; then
	RUN_PY_FILE=$FACS_LOCATION"/run.py -q"
else
	RUN_PY_FILE=$FACS_LOCATION"/run.py"
fi


if [ $ENSEMBLE_NUMBER -gt 1 ]; then
	# run a ensemble jobs
	echo "ENSEMBLE_MODE is enabled . . ." | tee -a "$LOG_RUN_JOB"

    for i in $(seq 1 $(($ENSEMBLE_NUMBER)))
    do

    	mpirun -n 1 python3 $RUN_PY_FILE --work_dir=$PWD/RUNS/$LOCATION_NAME"_"$i --location=$LOCATION_NAME --ci_multiplier=$CI_MULTIPLIER --transition_scenario=$TRANSITION_SCENARIO --transition_mode=$TRANSITION_MODE --output_dir=$OUTPUT_DIR &

    done

else
	# run a single run
	echo "ENSEMBLE_MODE is disabled . . ." | tee -a "$LOG_RUN_JOB"

	mpirun -n 1 python3 $RUN_PY_FILE --work_dir=$PWD/RUNS/$LOCATION_NAME --location=$LOCATION_NAME --ci_multiplier=$CI_MULTIPLIER --transition_scenario=$TRANSITION_SCENARIO --transition_mode=$TRANSITION_MODE --output_dir=$OUTPUT_DIR &

fi

wait


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

zip -r $result_file_name *.err *.out *.script *.yaml RUNS/



#----------------------------------------
#      Upload results to CKAN
#----------------------------------------
bash scripts/ckan_uploader.sh