#!/bin/bash

WIN_FONT_PATH=/cygdrive/c/WINDOWS/Fonts

. "$(dirname "$0")/jmeter-common.sh"

function usage {
  echo "Usage: $(basename "$0") -j test_result"
  echo -e "\t-j\tTest result (.jtl file)"
  exit 1
}

function create_response_file() {
  RESPONSE_FILE=${BASE_NAME}_${REQUEST_SANITIZED}.dat
  grep "$REQUEST," "$JTL_FILE" | sed 's/^\([0-9]\{10\}\)\([0-9]\{3\}\)\(,.*\)/\1.\2\3/' > "$RESPONSE_FILE"
}

function create_plot_file() {
  PLOT_FILE=${BASE_NAME}_${REQUEST_SANITIZED}.gnuplot
  OUT_FILE=${BASE_NAME}_${REQUEST_SANITIZED}.png

  {
    echo "set title '$REQUEST'"
    echo "set datafile separator \",\""
    echo "set xdata time"
    echo "set timefmt \"%s\""
    echo "set format x \"%H:%M\""
    echo "set grid"
    echo "set key box"
    echo "set key left"
    echo "set ylabel 'Response time (ms)'"
    echo "set xlabel 'Time (hour)'"
    echo "set y2tics"
    echo "set ytics nomirror"
    echo "set terminal png nocrop enhanced font arial 12 size 1280,1024"
    echo "set output '$OUT_FILE'"
    echo "plot '$RESPONSE_FILE' using 1:2 title 'Response time' with points pointsize 0,\\"
    echo "     '$RESPONSE_FILE' using 1:2 title 'Response time (bezier)' smooth bezier with lines"
  } > "$PLOT_FILE"
}

function remove_illegal_characters() {
  local ORIGINAL=$1
  echo "${ORIGINAL//[^a-zA-Z0-9.-]/_}"
}

# Parse command line arguments
while getopts "j:" OPTION
do
  case $OPTION in
    j ) JTL_FILE=$OPTARG;;
    * ) usage;; # Default option
  esac
done

# Check that the variable has been set
if [[ -z $JTL_FILE ]]; then
  usage
fi

check_that_file_exist "$JTL_FILE"

if [ -d $WIN_FONT_PATH ]
then
  export GDFONTPATH=$WIN_FONT_PATH
fi

BASE_NAME=$(basename "${JTL_FILE%\.*}")

IFS=$'\n'
for REQUEST in $(cut -d',' -f3 "$JTL_FILE" | sort | uniq);
do

  REQUEST_SANITIZED=$(remove_illegal_characters "$REQUEST")
  create_response_file
  create_plot_file

  gnuplot "$PLOT_FILE"
  if [ $? = 0 ]
  then
    log_info "$OUT_FILE successfully created"
    # Clean up
    rm "$PLOT_FILE"
    rm "$RESPONSE_FILE"
  else
    log_error "Failed to create $OUT_FILE!"
  fi

done
unset IFS
