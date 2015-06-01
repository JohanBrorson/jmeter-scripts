#!/bin/sh

LOGLEVEL=INFO
RESULTS_DIR=results

function usage {
  echo "Usage: `basename $0` -t test_plan [-q additional_properties_file]"
  echo -e "\t-t\tTest plan (.jmx file)"
  echo -e "\t-q\tAdditional properties file (optional)"
  exit 1
}

function log_error {
  echo "ERROR: $*"
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

# Check that the variable has been set
if [[ -z $JMX_FILE ]]; then
  usage
fi

# Check if the JMX file exist
if [ ! -f $JMX_FILE ]; then
  log_error "The file $JMX_FILE doesn't exist!"
fi

LOGFILE="$RESULTS_DIR/`date '+%Y%m%d%H%M'`-`basename ${JMX_FILE%\.*}`.log"
JTLFILE="$RESULTS_DIR/`date '+%Y%m%d%H%M'`-`basename ${JMX_FILE%\.*}`.jtl"

if [ ! -d "$RESULTS_DIR" ]; then
  mkdir "$RESULTS_DIR"
fi

# Run JMeter
java -jar `dirname $0`/ApacheJMeter.jar -n -t $JMX_FILE -L $LOGLEVEL -j $LOGFILE -l $JTLFILE -q $PROPERTIES_FILE
