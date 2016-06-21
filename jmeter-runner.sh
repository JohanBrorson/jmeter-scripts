#!/bin/bash

LOGLEVEL=INFO
RESULTS_DIR=results

. "$(dirname $0)/jmeter-common.sh"

function usage {
  echo "Usage: `basename $0` -t test_plan [-q additional_properties_file]"
  echo -e "\t-t\tTest plan (.jmx file)"
  echo -e "\t-q\tAdditional properties file (optional)"
  exit 1
}

# Parse command line arguments
while getopts "t:q:" OPTION
do
  case $OPTION in
    t ) JMX_FILE=$OPTARG;;
    q ) PROPERTIES_FILE=$OPTARG;;
    * ) usage;; # Default option
  esac
done

if [[ -z $JMETER_HOME ]]; then
  log_error "The variable JMETER_HOME is not defined"
fi

if [[ -z $JMX_FILE ]]; then
  usage
fi

check_that_file_exist "$JMX_FILE"

LOGFILE="$RESULTS_DIR/`date '+%Y%m%d%H%M'`-`basename ${JMX_FILE%\.*}`.log"
JTLFILE="$RESULTS_DIR/`date '+%Y%m%d%H%M'`-`basename ${JMX_FILE%\.*}`.jtl"

if [ ! -d "$RESULTS_DIR" ]; then
  mkdir "$RESULTS_DIR"
fi

# Run JMeter
java -jar $JMETER_HOME/bin/ApacheJMeter.jar -n -t $JMX_FILE -L $LOGLEVEL -j $LOGFILE -l $JTLFILE -q $PROPERTIES_FILE
